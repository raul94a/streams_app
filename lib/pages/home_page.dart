import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as dateFormatter;

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var stream = firestore.collection('frases').snapshots();
    var controlTexto = TextEditingController();
    //logica de insercion de documento en firestore
    _onPressFloatingActionButton() {
      showDialog(
          context: context,
          builder: (ctx) {
            return Dialog(
              elevation: 15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.18,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  children: [
                    TextField(
                      controller: controlTexto,
                      decoration: InputDecoration(
                          label: Text('frase'),
                          hintText: 'Introduce una frase'),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                          onPressed: () async {
                            firestore.collection('frases').add({
                              'frase': controlTexto.text,
                              'fecha': Timestamp.now()
                            });
                            Navigator.of(context);
                          },
                          child: Text('Enviar')),
                    )
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressFloatingActionButton,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
          child: StreamBuilder(
        stream: stream,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                value: 10,
              ),
            );
          }
          //obtenemos la lista de querySnapshots
          var doc = snapshot.data!.docs;
          //queremos que esta lista sea poblada con cada elemento de la lista de snapshots. SPOILER: el elemento es un Map
          //EXTENSIÓN, MUY UTIL PARA AHORRARSE COSAS QUE PROGRAMAR. Está definida más abajo.
          //Se pueden sacar a ficheros a parte e importarlas
          var lista = []; //doc.dameUnListMapStringDynamic();
          doc.forEach((element) {
            lista.add(element.data());
          });
          return FrasesMolonas(lista: lista);
        },
      )),
    );
  }
}

extension SuperExtension on List<QueryDocumentSnapshot<Map<String, dynamic>>> {
  List<Map<String, dynamic>> dameUnListMapStringDynamic() {
    //declaro la lista vacía que vamos a devolver LLENA
    List<Map<String, dynamic>> a = [];
    //uso el métodoforeach de List<QueryDocumentSnapshot<Map<Strign,dynamic>>> sobre
    //el que quiero operar de la forma que yo quiero (por eso es extensión)
    //y para devolver la estructura de datos que he definido en el método dameUnListMapStringDynamic
    forEach(Map<String, dynamic> element) {
      a.add(element);
    }

    return a;
  }
}

class FrasesMolonas extends StatelessWidget {
  const FrasesMolonas({
    Key? key,
    required this.lista,
  }) : super(key: key);

  final List lista;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: lista.length,
        itemBuilder: (_, i) {
          var elemento = lista[i];
          var frase = elemento['frase'];
          Timestamp timestamp = elemento['fecha'];
          var fecha =
              dateFormatter.DateFormat('dd/MM/yyyy').format(timestamp.toDate());
          var horas =
              dateFormatter.DateFormat('HH:mm:SS').format(timestamp.toDate());

          return Text(
            '$frase dicha en el ${fecha} a las $horas',
            overflow: TextOverflow.ellipsis,
          );
        });
  }
}
