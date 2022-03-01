import 'package:flutter/material.dart';
import 'package:flutter_sqlite_crud/db_helper.dart';
import 'package:flutter_sqlite_crud/student_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  Future<List<Student>> students;
  String _studentName;
  bool isUpdate = false;
  int studentIdForUpdate;
  DBHelper dbHelper;
  final _studentNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    refreshStudentList();
  }

  refreshStudentList() {
    setState(() {
      students = dbHelper.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'CRUD Com Flutter e SQLite',
      )),
      body: Column(
        children: <Widget>[
          Form(
            key: _formStateKey,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Insira o Nome Completo';
                      }
                      if (value.trim() == "")
                        return "Espaço em Branco Não É Válido!!!";
                      return null;
                    },
                    onSaved: (value) {
                      _studentName = value;
                    },
                    controller: _studentNameController,
                    decoration: InputDecoration(
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.purple,
                                width: 2,
                                style: BorderStyle.solid)),
                        // hintText: "Student Name",
                        labelText: "Nome do Usuário",
                        icon: Icon(
                          Icons.business_center,
                          color: Colors.blue,
                        ),
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        )),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Colors.green,
                child: Text(
                  (isUpdate ? 'ATUALIZAR' : 'ADICIONAR'),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (isUpdate) {
                    if (_formStateKey.currentState.validate()) {
                      _formStateKey.currentState.save();
                      dbHelper
                          .update(Student(studentIdForUpdate, _studentName))
                          .then((data) {
                        setState(() {
                          isUpdate = false;
                        });
                      });
                    }
                  } else {
                    if (_formStateKey.currentState.validate()) {
                      _formStateKey.currentState.save();
                      dbHelper.add(Student(null, _studentName));
                    }
                  }
                  _studentNameController.text = '';
                  refreshStudentList();
                },
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              RaisedButton(
                color: Colors.red,
                child: Text(
                  //cancelar UPDATE
                  (isUpdate ? 'CANCELAR' : 'LIMPAR'),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _studentNameController.text = '';
                  setState(() {
                    isUpdate = false;
                    studentIdForUpdate = null;
                  });
                },
              ),
            ],
          ),
          const Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
              future: students,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return generateList(snapshot.data);
                }
                if (snapshot.data == null || snapshot.data.length == 0) {
                  return Text('Nenhum dado encontrado');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('NOME'),
            ),
            DataColumn(
              label: Text('DELETAR'),
            )
          ],
          rows: students
              .map(
                (student) => DataRow(
                  cells: [
                    DataCell(
                      Text(student.name),
                      onTap: () {
                        setState(() {
                          isUpdate = true;
                          studentIdForUpdate = student.id;
                        });
                        _studentNameController.text = student.name;
                      },
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[800],
                        ),
                        onPressed: () {
                          dbHelper.delete(student.id);
                          refreshStudentList();
                        },
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
