import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobminder/blocs/applications/applications_bloc.dart';
import 'package:jobminder/blocs/applications/applications_states.dart';
import 'package:jobminder/blocs/applications_detailes/applications_detailes_bloc.dart';
import 'package:jobminder/blocs/compnies/compnies_bloc.dart';
import 'package:jobminder/main.dart';
import 'package:jobminder/modules/application.dart';
import 'package:jobminder/modules/company.dart';
import 'package:jobminder/screens/application_details_screen.dart';
import 'package:jobminder/screens/company_screen.dart';
import 'package:jobminder/utilites/db.dart';

class ApplicationsScreen extends StatefulWidget {
  final Company company;
  const ApplicationsScreen({super.key, required this.company});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late ApplicationsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<ApplicationsBloc>();
    locator.get<FirebaseService>().listenToApplications(bloc, widget.company);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company.name),
        leading: BackButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => CompaniesBloc(),
                child: const CompaniesScreen(),
              ),
            ),
          );
        }),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return ApplicationForm(
                    bloc: bloc,
                    comp: widget.company,
                  );
                },
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocBuilder<ApplicationsBloc, ApplicationsState>(
            builder: (context, state) {
          if (state is ApplicationsInitialState ||
              state is ApplicationsSuccessAddState) {
            locator
                .get<FirebaseService>()
                .listenToApplications(bloc, widget.company);

            return ListView.builder(
                itemCount: state.props.length,
                itemBuilder: (context, index) {
                  Application app = state.props[index] as Application;
                  return GestureDetector(
                    onTap: () {
                      // print(widget.companies[index].name);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => ApplicationDetailsBloc(app),
                            child: const ApplicationDetailsScreen(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(app.postion),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return const Text("other");
          }
        }),
      ),
    );
  }
}

class ApplicationForm extends StatefulWidget {
  final ApplicationsBloc bloc;
  final Company comp;

  const ApplicationForm({super.key, required this.bloc, required this.comp});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  late JobType newType = JobType.fulltime;
  late WorkModle newModle = WorkModle.office;
  TextEditingController id = TextEditingController();
  TextEditingController pos = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ID',
                ),
                controller: id,
              ),
              const SizedBox(
                height: 25,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Postion',
                ),
                controller: pos,
              ),
              const SizedBox(
                height: 25,
              ),
              DropdownButton<JobType>(
                  value: newType,
                  onChanged: (value) {
                    setState(() {
                      newType = value!;
                    });
                  },
                  items: JobType.values.map((JobType classType) {
                    return DropdownMenuItem<JobType>(
                        value: classType, child: Text(classType.name));
                  }).toList()),
              const SizedBox(
                height: 25,
              ),
              DropdownButton<WorkModle>(
                  value: newModle,
                  onChanged: (value) {
                    setState(() {
                      newModle = value!;
                    });
                  },
                  items: WorkModle.values.map((WorkModle classType) {
                    return DropdownMenuItem<WorkModle>(
                        value: classType, child: Text(classType.name));
                  }).toList()),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  // ApplicationState newState = ApplicationState(newStateStatus, dueDate, DateTime.now());
                  // widget.bloc.add(AddStateEvent(widget.application, newState));
                  locator.get<FirebaseService>().addApplication(Application(
                        pos.text,
                        newModle,
                        newType,
                        widget.comp,
                        id.text,
                      ));
                  // ignore: invalid_use_of_visible_for_testing_member
                  widget.bloc.emit(const ApplicationsInitialState());

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
