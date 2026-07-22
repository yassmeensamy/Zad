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

class _Clock {
  DateTime _now = DateTime.utc(2026, 1, 1);

  DateTime call() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

class _StubQuizRepository implements QuizRepository {
  _StubQuizRepository(this._questions);

  final List<QuestionModel> _questions;
  QuizSubmissionRequest? captured;

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

QuestionModel _question(int id) => QuestionModel(
      id: id,
      text: 'Q$id',
      correctIndex: _rightChoice,
      choices: const [
        ChoiceModel(index: _rightChoice, text: 'right'),
        ChoiceModel(index: _wrongChoice, text: 'wrong'),
      ],
    );

void main() {
  late _Clock clock;
  late _StubQuizRepository repo;

  Future<QuizCubit> buildCubit(int questionCount) async {
    clock = _Clock();
    repo = _StubQuizRepository([
      for (var i = 0; i < questionCount; i++) _question(101 + i),
    ]);
    final cubit = QuizCubit(
      quizRepository: repo,
      quizEventService: QuizEventService(),
      supportTicketsRepository: _NoopSupportRepository(),
      now: clock.call,
    );
    await cubit.loadQuiz(1);
    return cubit;
  }

  group('first-try speed tiers', () {
    test('under 10s scores 3 points per question', () async {
      final cubit = await buildCubit(3);

      for (var i = 0; i < 3; i++) {
        clock.advance(const Duration(seconds: 4));
        cubit.selectAnswer(_rightChoice);
        cubit.next();
      }

      expect(cubit.state.points, 14);
      expect(cubit.state.perfectBonusAwarded, isTrue);
      await cubit.close();
    });

    test('between 10s and 20s scores 2 points and breaks the perfect run',
        () async {
      final cubit = await buildCubit(3);

      for (var i = 0; i < 3; i++) {
        clock.advance(const Duration(seconds: 12));
        cubit.selectAnswer(_rightChoice);
        cubit.next();
      }

      expect(cubit.state.points, 6);
      expect(cubit.state.perfectBonusAwarded, isFalse);
      expect(cubit.state.isPerfectRun, isFalse);
      await cubit.close();
    });

    test('over 20s scores 1 point', () async {
      final cubit = await buildCubit(3);

      for (var i = 0; i < 3; i++) {
        clock.advance(const Duration(seconds: 25));
        cubit.selectAnswer(_rightChoice);
        cubit.next();
      }

      expect(cubit.state.points, 3);
      expect(cubit.state.perfectBonusAwarded, isFalse);
      await cubit.close();
    });
  });

  group('retries', () {
    test('a wrong answer costs a point and the 2nd try earns one', () async {
      final cubit = await buildCubit(3);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_wrongChoice);
      cubit.next();
      cubit.selectAnswer(_rightChoice);
      cubit.next();

      expect(cubit.state.round, 2);
      cubit.selectAnswer(_rightChoice);

      expect(cubit.state.points, 6);
      expect(cubit.state.firstTryCorrect, 2);
      expect(cubit.state.perfectBonusAwarded, isFalse);
      await cubit.close();
    });

    test('the 3rd try earns half a point', () async {
      final cubit = await buildCubit(2);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_wrongChoice);
      cubit.next();
      cubit.selectAnswer(_wrongChoice);
      cubit.next();

      expect(cubit.state.round, 3);
      cubit.selectAnswer(_rightChoice);

      expect(cubit.state.points, 1.5);
      await cubit.close();
    });

    test('the 4th try and beyond earn nothing', () async {
      final cubit = await buildCubit(2);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      for (var i = 0; i < 3; i++) {
        cubit.selectAnswer(_wrongChoice);
        cubit.next();
      }

      expect(cubit.state.round, 4);
      cubit.selectAnswer(_rightChoice);

      expect(cubit.state.points, 0);
      await cubit.close();
    });
  });

  test('the running total never goes negative', () async {
    final cubit = await buildCubit(1);

    for (var i = 0; i < 4; i++) {
      cubit.selectAnswer(_wrongChoice);
      expect(cubit.state.points, greaterThanOrEqualTo(0));
      cubit.next();
    }

    expect(cubit.state.points, 0);
    await cubit.close();
  });

  group('perfect-run bonus', () {
    test('is withheld when a single answer is slow', () async {
      final cubit = await buildCubit(2);

      cubit.selectAnswer(_rightChoice);
      cubit.next();
      clock.advance(const Duration(seconds: 11));
      cubit.selectAnswer(_rightChoice);

      expect(cubit.state.points, 5);
      expect(cubit.state.perfectBonusAwarded, isFalse);
      await cubit.close();
    });

    test('is withheld when a question needed a retry', () async {
      final cubit = await buildCubit(2);

      cubit.selectAnswer(_wrongChoice);
      cubit.next();
      cubit.selectAnswer(_rightChoice);
      cubit.next();
      cubit.selectAnswer(_rightChoice);

      expect(cubit.state.points, 4);
      expect(cubit.state.perfectBonusAwarded, isFalse);
      await cubit.close();
    });
  });

  test('the submitted total is the rounded running score', () async {
    final cubit = await buildCubit(2);

    cubit.selectAnswer(_rightChoice);
    cubit.next();
    cubit.selectAnswer(_wrongChoice);
    cubit.next();
    cubit.selectAnswer(_wrongChoice);
    cubit.next();
    cubit.selectAnswer(_rightChoice);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.points, 1.5);
    expect(repo.captured!.pointsEarned, 2, reason: '1.5 rounds to 2');
    await cubit.close();
  });

  test('maxPoints accounts for the 3-point tier plus the bonus', () async {
    final cubit = await buildCubit(4);
    expect(cubit.state.maxPoints, 4 * 3 + 5);
    await cubit.close();
  });
}
