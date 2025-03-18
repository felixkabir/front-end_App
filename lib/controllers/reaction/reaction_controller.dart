import 'package:stivy/models/reaction/reaction_model.dart';
import 'package:stivy/services/reaction/reaction_service.dart';

class ReactionController {
  final ReactionService _reactionService = ReactionService();

  Future<ReactionModel> reactToPost({
    required String userId,
    required String postId,
  }) async {
    return await _reactionService.createReactionToPost(
      userId: userId,
      postId: postId,
    );
  }

  Future<ReactionModel> reactToEvent({
    required String userId,
    required String eventId,
  }) async {
    return await _reactionService.createReactionToEvent(
      userId: userId,
      eventId: eventId,
    );
  }

  Future<void> removeReactionToPost(String postId, String userId) async { 
    await _reactionService.deleteReactionToPost(userId, postId);
  }

  Future<void> removeReaction(String reactionId) async {
    await _reactionService.deleteReactionToEvent(reactionId);
  }
}