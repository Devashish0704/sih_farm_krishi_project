import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import './TutorialState.dart';
import '../../../models/Tutorial.dart';

class TutorialBloc {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  TutorialBloc(bool isEnglish) {
    if (isEnglish) {
      _fetchEnglishTutorials();
    } else {
      _fetchHindiTutorials();
    }
  }

  final StreamController<TutorialState> _stateController =
      StreamController<TutorialState>.broadcast();

  Future<void> _fetchEnglishTutorials() async {
    try {
      final QuerySnapshot res = await _db.collection('englishTutorials').get();
      final List<Tutorial> tutorials =
          res.docs.map((doc) => Tutorial.fromFirestore(doc)).toList();
      _setState(TutorialState.onSuccess(tutorials));
    } catch (e) {
      _setState(TutorialState.onError('Something went wrong'));
    }
  }

  Future<void> _fetchHindiTutorials() async {
    try {
      final QuerySnapshot res = await _db.collection('hindiTutorials').get();
      final List<Tutorial> tutorials =
          res.docs.map((doc) => Tutorial.fromFirestore(doc)).toList();
      _setState(TutorialState.onSuccess(tutorials));
    } catch (e) {
      _setState(TutorialState.onError('Something went wrong'));
    }
  }

  void _setState(TutorialState state) {
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void refresh(bool isEnglish) {
    if (isEnglish) {
      _fetchEnglishTutorials();
    } else {
      _fetchHindiTutorials();
    }
  }

  void dispose() {
    _stateController.close();
  }

  Stream<TutorialState> get state => _stateController.stream;
}
