// dart class
class ApplicationState {
  final JobStatus jobStatuses;
  final DateTime deadline;
  final DateTime update;

  ApplicationState(this.jobStatuses, this.deadline, this.update);

  ApplicationState.fromJson(Map<String, dynamic> json)
      : jobStatuses = JobStatus.values.firstWhere((e) => e.name == (json['state'] as String)) ,
        deadline = DateTime.parse(json['deadline']),
        update = DateTime.parse(json['update']);

}

enum JobStatus {
  jobForm, 
  technicalAssessment,
  interview,
  accpeted,
  rejected,
  jobOffer
}
