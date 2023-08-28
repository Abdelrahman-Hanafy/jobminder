import 'package:jobminder/modules/application_state.dart';
import 'company.dart';

class Application{

  final String postion;
  late List<ApplicationState> appStates = [];
  final WorkModle workModle;
  final JobType jobType;
  final Company company;
  late String notes;

  Application(this.postion, this.workModle, this.jobType, this.company);
  
}

enum WorkModle{
  remote, office, hybrid
}

enum JobType{
  fulltime, parttime, freelance, internship, contract
}