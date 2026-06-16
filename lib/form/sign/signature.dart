import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';


class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  SignFormNew createState() => SignFormNew();
}

class SignFormNew extends State<SignForm> {
   SignatureController controller = SignatureController(
     penStrokeWidth: 5,
     penColor: Colors.white,
     exportBackgroundColor: Colors.transparent,
     exportPenColor: Colors.black,
     onDrawStart: () => log('onDrawStart called!'),
     onDrawEnd: () => log('onDrawEnd called!'),

   );
   @override
   void initState() {
     super.initState();
     controller.addListener(() => log('Value changed'));
   }

   @override
   void dispose() {

     controller.dispose();
     super.dispose();
   }

   Future<void> exportImage(BuildContext context) async {
     if (controller.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           key: Key('snackbarPNG'),
           content: Text('No content'),
         ),
       );
       return;
     }

     final Uint8List? data =
     await controller.toPngBytes(height: 500, width: 500);
     if (data == null) {
       return;
     }

     if (!mounted) return;

     if (context.mounted) Navigator.of(context).maybePop(data);
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text('Digital Signature',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: Signature(
        key: const Key('signature'),
        controller: controller,
        height: 300,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.teal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                key: const Key('exportPNG'),
                icon: const Icon(Icons.image),
                color: Colors.black,
                onPressed: () => exportImage(context),
                tooltip: 'Export Image',
              ),

              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.undo());
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.redo());
                },
                tooltip: 'Redo',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.clear());
                },
                tooltip: 'Clear',
              ),
              // STOP Edit
              IconButton(
                key: const Key('stop'),
                icon: Icon(
                  controller.disabled ? Icons.pause : Icons.play_arrow,
                ),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.disabled = !controller.disabled);
                },
                tooltip: controller.disabled ? 'Pause' : 'Play',
              ),
            ],
          ),
        ),
      ),
    );
  }
}