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
import 'package:my_app/features/support_tickets/data/models/create_ticket_request.dart';
import 'package:my_app/features/support_tickets/data/models/ticket_model.dart';
import 'package:my_app/features/support_tickets/data/repositories/support_tickets_repository.dart';

/// Captures the submission so the test can assert the exact per-question
/// correctness that reaches the backend.
class _CapturingQuizRepository implements QuizRepository {
  _CapturingQuizRepository(this._questions);

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

QuestionModel _question(int id) => QuestionModel(
      id: id,
      text: 'Q$id',
      correctIndex: 0,
      choices: const [
        ChoiceModel(index: 0, text: 'right'),
        ChoiceModel(index: 1, text: 'wrong'),
      ],
    );

void main() {
  test(
    'a question missed first then fixed on retry is submitted as isCorrect: true',
    () async {
      final questions = [_question(101), _question(102), _question(103)];
      final repo = _CapturingQuizRepository(questions);
      final cubit = QuizCubit(
        quizRepository: repo,
        quizEventService: QuizEventService(),
        supportTicketsRepository: _NoopSupportRepository(),
      );

      await cubit.loadQuiz(1);

      // Round 1: Q101 correct, Q102 wrong, Q103 correct.
      cubit.selectAnswer(0); // Q101 correct
      cubit.next();
      cubit.selectAnswer(1); // Q102 wrong -> retry queue
      cubit.next();
      cubit.selectAnswer(0); // Q103 correct (last, but retry pending)
      cubit.next();

      // Retry round: Q102 answered correctly now (round 2).
      cubit.selectAnswer(0); // fixes Q102 -> auto-submit fires
      await Future<void>.delayed(Duration.zero);

      final answers = {
        for (final a in repo.captured!.answers) a.questionId: a.isCorrect,
      };

      expect(answers[101], isTrue, reason: 'correct on first try');
      expect(answers[103], isTrue, reason: 'correct on first try');
      expect(
        answers[102],
        isTrue,
        reason: 'wrong on first try but fixed on retry still counts as correct',
      );

      await cubit.close();
    },
  );
}
