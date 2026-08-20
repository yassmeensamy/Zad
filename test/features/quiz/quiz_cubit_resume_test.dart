import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/offline/data/models/pending_answer_input.dart';
import 'package:my_app/features/quiz/core/quiz_event_service.dart';
import 'package:my_app/features/quiz/data/models/choice_model.dart';
import 'package:my_app/features/quiz/data/models/question_model.dart';
import 'package:my_app/features/quiz/data/models/quiz_questions_response.dart';
import 'package:my_app/features/quiz/data/models/quiz_submission_request.dart';
import 'package:my_app/features/quiz/data/models/quiz_submission_response.dart';
import 'package:my_app/features/quiz/data/repositories/quiz_repository.dart';
import 'package:my_app/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:my_app/features/quiz/presentation/cubit/quiz_state.dart';
import 'package:my_app/features/support_tickets/data/models/create_ticket_request.dart';
import 'package:my_app/features/support_tickets/data/models/ticket_model.dart';
import 'package:my_app/features/support_tickets/data/repositories/support_tickets_repository.dart';

class _StubQuizRepository implements QuizRepository {
  _StubQuizRepository(this._questions);

  final List<QuestionModel> _questions;
  QuizSubmissionRequest? captured;
  int submitCalls = 0;

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) async =>
      QuizQuestionsResponse(
        levelId: levelId,
        title: 'Test',
        passingGrade: 0,
        questions: _questions,
      );

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request, {
    List<PendingAnswerInput>? selectedAnswers,
  }) async {
    submitCalls++;
    captured = request;
    return QuizSubmissionResponse(
      levelId: levelId,
      userId: 'u1',
      totalQuestions: request.answers.length,
      correctAnswers: request.answers.where((a) => a.isCorrect).length,
      passed: true,
      nextLevelUnlocked: false,
      pointsEarned: request.pointsEarned,
      totalPoints: request.pointsEarned,
    );
  }

  @override
  Future<void> resetAll() async {}
}

class _NoopSupportRepository implements SupportTicketsRepository {
  @override
  Future<TicketModel> closeTicket(String id) => throw UnimplementedError();
  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) =>
      throw UnimplementedError();
  @override
  Future<TicketModel> getTicketById(String id) => throw UnimplementedError();
  @override
  Future<List<TicketModel>> getTickets() => throw UnimplementedError();
}

const _rightChoice = 0;
const _wrongChoice = 1;

QuestionModel _question(int id, {bool answered = false}) => QuestionModel(
      id: id,
      text: 'Q$id',
      correctIndex: _rightChoice,
      // `isAnsweredCorrectly` is an int now: >0 cleared, <0 negated retry count.
      isAnsweredCorrectly: answered ? 1 : 0,
      choices: const [
        ChoiceModel(index: _rightChoice, text: 'right'),
        ChoiceModel(index: _wrongChoice, text: 'wrong'),
      ],
    );

void main() {
  Future<QuizCubit> load(
    List<QuestionModel> questions, {
    required _StubQuizRepository repo,
    bool review = false,
  }) async {
    final cubit = QuizCubit(
      quizRepository: repo,
      quizEventService: QuizEventService(),
      supportTicketsRepository: _NoopSupportRepository(),
    );
    await cubit.loadQuiz(1, review: review);
    return cubit;
  }

  group('resuming a level', () {
    test('opens on the questions not answered yet', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102, answered: true),
        _question(103),
        _question(104),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      expect(
        cubit.state.allQuestions.map((q) => q.id),
        [103, 104],
        reason: 'isAnsweredCorrectly == 1 questions are dropped',
      );
      expect(cubit.state.currentQuestion!.id, 103);
      expect(cubit.state.totalQuestions, 2);
      expect(cubit.state.roundLength, 2);

      await cubit.close();
    });

    test('keeps the answered ones browsable and locked', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102, answered: true),
        _question(103),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      final carried = cubit.state.history;
      expect(carried.map((e) => e.question.id), [101, 102]);
      expect(carried.every((e) => e.fromPreviousAttempt), isTrue);
      expect(
        carried.every((e) => e.isCorrect),
        isTrue,
        reason: 'they render revealed on the correct choice',
      );
      expect(
        cubit.state.answeredIds,
        isEmpty,
        reason: 'carried-over questions are not part of this attempt',
      );

      await cubit.close();
    });

    test('carries nothing over in review mode', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102),
      ]);
      final cubit = await load(repo._questions, repo: repo, review: true);

      expect(cubit.state.history, isEmpty);
      await cubit.close();
    });

    test('keeps the whole level when nothing has been answered', () async {
      final repo = _StubQuizRepository([_question(101), _question(102)]);
      final cubit = await load(repo._questions, repo: repo);

      expect(cubit.state.allQuestions.map((q) => q.id), [101, 102]);
      await cubit.close();
    });

    test('falls back to the full level when everything is answered', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102, answered: true),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      expect(
        cubit.state.allQuestions.map((q) => q.id),
        [101, 102],
        reason: 'never open an empty quiz',
      );
      await cubit.close();
    });

    test('review mode replays the whole level', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102),
      ]);
      final cubit = await load(repo._questions, repo: repo, review: true);

      expect(cubit.state.allQuestions.map((q) => q.id), [101, 102]);
      await cubit.close();
    });

    test('the perfect-run bonus still lands on the resumed subset', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102),
        _question(103),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_rightChoice);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.perfectBonusAwarded, isTrue);
      expect(cubit.state.points, 2 * 3 + 5);
      await cubit.close();
    });
  });

  group('partial submit', () {
    test('sends only the questions the user answered', () async {
      final repo = _StubQuizRepository([
        _question(101),
        _question(102),
        _question(103),
        _question(104),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_wrongChoice);

      await cubit.submit();

      final answers = {
        for (final a in repo.captured!.answers) a.questionId: a.isCorrect,
      };
      expect(answers.keys.toSet(), {101, 102});
      expect(answers[101], isTrue);
      expect(answers[102], isFalse, reason: 'answered, still wrong on exit');

      await cubit.close();
    });

    test('a completed attempt still sends every question', () async {
      final repo = _StubQuizRepository([_question(101), _question(102)]);
      final cubit = await load(repo._questions, repo: repo);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_rightChoice);
      await Future<void>.delayed(Duration.zero);

      expect(
        repo.captured!.answers.map((a) => a.questionId).toSet(),
        {101, 102},
      );
      await cubit.close();
    });

    test('sends nothing when no question was answered', () async {
      final repo = _StubQuizRepository([_question(101), _question(102)]);
      final cubit = await load(repo._questions, repo: repo);

      await cubit.submit();

      expect(repo.submitCalls, 0);
      await cubit.close();
    });

    test('sends nothing when only carried-over questions exist', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      await cubit.submit();

      expect(repo.submitCalls, 0);
      await cubit.close();
    });

    test('excludes carried-over questions from the payload', () async {
      final repo = _StubQuizRepository([
        _question(101, answered: true),
        _question(102),
        _question(103),
      ]);
      final cubit = await load(repo._questions, repo: repo);

      cubit.selectAnswer(_rightChoice);

      await cubit.submit();

      expect(
        repo.captured!.answers.map((a) => a.questionId),
        [102],
        reason: '101 was answered in an earlier attempt',
      );
      await cubit.close();
    });
  });
}
