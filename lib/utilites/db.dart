// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:jobminder/blocs/applications/applications_bloc.dart';
import 'package:jobminder/blocs/applications/applications_events.dart';
import 'package:jobminder/blocs/applications_detailes/applications_detailes_bloc.dart';
import 'package:jobminder/blocs/applications_detailes/applications_detailes_events.dart';
import 'package:jobminder/blocs/compnies/compnies_bloc.dart';
import 'package:jobminder/blocs/compnies/compnies_events.dart';
import 'package:jobminder/blocs/questions/questions_bloc.dart';
import 'package:jobminder/blocs/questions/questions_events.dart';
import 'package:jobminder/modules/application.dart';
import 'package:jobminder/modules/application_state.dart';
import 'package:jobminder/modules/company.dart';
import 'package:jobminder/modules/question.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // ignore: avoid_init_to_null
  late User? _user = null;

  bool isSignedIn() {
    return _user != null;
  }

  Future<String> listenUserName() async{
    final snapshot =
        await _database.ref().child('${_user?.uid}/UserName').get();
    if (snapshot == null || snapshot.value == null){
      return "";
    }
    final name = snapshot.value as String;

    return name;
  }

  Future<Map<String, int>> listenToApplicationStatesNumber() async {
      Map <String, int> counters = {
        "Accepted": 0,
        "Rejected": 0,
      };

      final snapshot =
        await _database.ref().child('${_user?.uid}/States').get();
      if (snapshot == null || snapshot.value == null){
      return counters;
    }
      final jobs = Map<String, Object>.from(snapshot.value as dynamic);
      jobs.forEach((key, value) {
        // final tmp = value as Map<String, dynamic>;
        // print(value);
        final states = Map<String, Object>.from(value as dynamic);
        states.forEach((key, value) {
          final state = ApplicationState.fromJson(
            Map<String, Object>.from(value as dynamic));
          if (state.jobStatuses == JobStatus.accpeted) {
            counters["Accepted"] = counters["Accepted"]! + 1;
          } else if (state.jobStatuses == JobStatus.rejected) {
            counters["Rejected"] = counters["Rejected"]! + 1;
          }
        });
      });

      return counters;
    }

  Future<int> listenToAppsNumber() async {
    int count = 0;
    final snapshot =
        await _database.ref().child('${_user?.uid}/Applications').get();
    if (snapshot == null || snapshot.value == null) {
      return count;
    }
    final comps = Map<String, Object>.from(snapshot.value as dynamic);
    comps.forEach((key, value) {
      final apps = Map<String, Object>.from(value as dynamic);
      apps.forEach((key, value) {
        count++;
      });
    });

    return count;
  }

  void addApplication(Application app) {
    if (!isSignedIn()) {
      print("no user");
      return;
    }
    final ref =
        _database.ref().child('${_user?.uid}/Applications/${app.company.name}');
    ref.push().set({
      "ID": app.id,
      "postion": app.postion,
      "workModle": app.workModle.name,
      "jobType": app.jobType.name,
    });
  }

  void listenToApplications(ApplicationsBloc bloc, Company comp) {
    _database
        .ref()
        .child('${_user?.uid}/Applications/${comp.name}')
        .get()
        .then((snapshot) {
      if (snapshot.value == null) {
        return;
      }
      List<Application> applications = [];
      final apps = Map<String, Object>.from(snapshot.value as dynamic);
      apps.forEach((key, value) {
        // final tmp = value as Map<String, dynamic>;
        // print(value);
        Application app = Application.fromJson(
            Map<String, Object>.from(value as dynamic), comp);
        bloc.add(AddApplicationEvent(app, applications));
      });
    });
  }

  void addApplicationState(ApplicationState appState, String appId) {
    if (!isSignedIn()) {
      print("no user");
      return;
    }
    final ref = _database.ref().child('${_user?.uid}/States/$appId');
    ref.push().set({
      "state": appState.jobStatuses.name,
      "deadline": _formatDate(appState.deadline),
      "update": _formatDate(appState.update)
    });
  }

  void listenToApplicationStates(ApplicationDetailsBloc bloc, Application app) {
    _database
        .ref()
        .child('${_user?.uid}/States/${app.id}')
        .get()
        .then((snapshot) {
      if (snapshot.value == null) {
        return;
      }
      final apps = Map<String, Object>.from(snapshot.value as dynamic);

      apps.forEach((key, value) {
        // print(value);
        ApplicationState appState = ApplicationState.fromJson(
            Map<String, Object>.from(value as dynamic));
        app.appStates.clear();
        bloc.add(AddStateEvent(app, appState));
      });
    });
  }

  // ignore: non_constant_identifier_names
  void addCompany(CompanyName) {
    if (!isSignedIn()) {
      print("no user");
      return;
    }
    final ref = _database.ref().child('${_user?.uid}/Companies/');
    ref.push().set(CompanyName);
  }

  void listenToCompanies(CompaniesBloc bloc) {
    _database.ref().child('${_user?.uid}/Companies/').get().then((snapshot) {
      if (snapshot.value == null) {
        return;
      }
      List<Company> companies = [];
      final comps = Map<String, Object>.from(snapshot.value as dynamic);
      comps.forEach((key, value) {
        Company c = Company(name: value as String);
        bloc.add(AddcompanyEvent(c, companies));
      });
    });
  }

  void addQuestion(Question q) {
    if (!isSignedIn()) {
      print("no user");
      return;
    }
    final ref = _database.ref().child('${_user?.uid}/Questions/');
    ref.push().set({"Question": q.question, "Answer": q.answer});
  }

  void listenToQuestions(QuestionsBloc bloc) {
    _database.ref().child('${_user?.uid}/Questions/').get().then((snapshot) {
      if (snapshot.value == null) {
        return;
      }
      List<Question> questions = [];
      final qs = Map<String, Object>.from(snapshot.value as dynamic);
      qs.forEach((key, value) {
        Question q =
            Question.fromJson(Map<String, Object>.from(value as dynamic));
        bloc.add(AddQuestionEvent(q, questions));
      });
    });
  }

  void _addUserName(uname) {
    if (!isSignedIn()) {
      print("no user");
      return;
    }
    final ref = _database.ref().child('${_user?.uid}/UserName/');
    ref.set(uname);
  }

  void signUpWithEmailAndPassword(
      String email, String password, String userName) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
      _addUserName(userName);
    } catch (e) {
      print("Some error occured");
    }
  }

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _user = credential.user;
    } catch (e) {
      print("Some error occured");
    }
  }

  void signOut() {
    _firebaseAuth.signOut();
    _user = null;
  }

  void listenToApplicationDetails(ApplicationDetailsBloc bloc) {}
}

String _formatDate(DateTime date) {
  return '${NumberFormat('00').format(date.year)}-${NumberFormat('00').format(date.month)}-${NumberFormat('00').format(date.day)}';
}
