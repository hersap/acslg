import 'dart:async';
import 'dart:io';
import 'package:acslg/form/sign/signature.dart';
import 'package:acslg/pekerjaan/masuk/tab_1.dart';
import 'package:acslg/pekerjaan/masuk/tab_2.dart' hide ProsesDetail, Progres;
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';

class UpdateSPKForm extends StatefulWidget {
  const UpdateSPKForm({super.key, required this.datalapsend, required this.dataproses});

  final ProsesDetail datalapsend;
  final Progres dataproses;
  @override
  State<UpdateSPKForm> createState() => _UpdateSPKFormState();
}

List <String> teknisi = <String>[
  '-',
  'Adji',
  'Anam',
  'Aris',
  'Dika',
  'Fatkhan',
  'Heri',
  'Jesisca',
  'Irawan',
  'Ricky',
  'Timotius'];

String noSPK = '';


class DataSparepart{
  final String part;
  final String jumlahpart;
  
  DataSparepart({
    required  this.part,
    required this.jumlahpart
  });

  DataSparepart.fromJson(Map<String, dynamic> json)
  : part = json['part'],
    jumlahpart = json['jumlah'];

  Map<String, dynamic> toJson() {
    return {
      'part' : part,
      'jumlah' : jumlahpart,
    };
  }
}

class _UpdateSPKFormState extends State<UpdateSPKForm> {
  
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  String _statusMessage = "";
  
  bool isLoading = false;
  bool spk = false;
  String ? sumberpekerjaan;
  String part = '';
  bool uploaded = false;
 
  Directory ? _tempDirectory;
  File ? signImage;
  List<File> selectedImage = [];
  List<String> selectedImagePath = [];
  final picker = ImagePicker();

  final TextEditingController tindakanKerja = TextEditingController();
  final TextEditingController evaluasiSelesai = TextEditingController();

  bool prosesIPS = false;
  bool proses3 = false;


  Future sendBuatSPK() async {
    String hasilproses = '';
    if (prosesIPS) {
      hasilproses = 'IPS';
    } 
    if (proses3) {
      hasilproses = 'Rekanan';
    }

    DateTime now = DateTime.now();
    String bulan = DateFormat('MM').format(now); //Bulan Sekarang
    if (int.parse(bulan) < 10) {
    } else{
    }
     
    String tahun = DateFormat('yyyy').format(now); // Tahun Sekarang
    tahun.substring(2, 4);
    String uri = "https://ipsrsslg.my.id/ipscrud/buatSPKproses_update.php";

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'nomorlap' : widget.datalapsend.nomor,
        'nospk' : widget.dataproses.nomorspk,
        'tindakan' : tindakanKerja.text,
        'keterangan' : evaluasiSelesai.text,
        'hasilproses' : hasilproses,
      }).timeout(Duration(seconds: 10), onTimeout: (){ return http.Response('Error: Timeout', 408); });

      if (response.body == '1'){
        spk = true;
      }
    } on TimeoutException catch(_) { 
      return await failAlert(text: 'Connection Timeout!');
    } catch (e) {
      await failAlert(text: '$e');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    noSPK = widget.dataproses.nomorspk;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Form Selesai Proses : ${widget.datalapsend.jenislaporan}',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
          leading: const BackButton(
            color: Colors.white,
          ),
          centerTitle: true,
        ),

        body: formProsesSelesai(context)
      )
    );
  }

  SingleChildScrollView formProsesSelesai(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Padding(padding: const EdgeInsets.all(20),
              child: Container(
                width: 370,
                decoration: BoxDecoration(
                  border: Border.all()
                ),
                child: Padding(padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      maxLines: null,
                      style: TextStyle(fontSize: 12),
                      controller: tindakanKerja,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                        hintText: "Masukkan update tindakan/hasil"
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        maxLines: null,
                        style: TextStyle(fontSize: 12),
                        controller: evaluasiSelesai,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                          hintText: "Masukkan update keterangan"
                        ),
                      ),
                    )
                  ],
                )
                )
              ), 
              ),
              Padding(padding: const EdgeInsets.only(top: 10, left: 50),
              child: Container(width: 150, height: 30, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),),
              ),
              const Padding(padding: EdgeInsets.only(top: 10, left: 60),
              child: Text("Update Hasil Pekerjaan", style: TextStyle(fontSize: 12),)
              )
            ],
          ),
          Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Container(
                height: 200,
                width: 370,
                decoration: BoxDecoration(
                  border: Border.all()
                ),
                child: Padding(padding: const EdgeInsets.all(10),
                  child: 
                  selectedImage.isNotEmpty ?
                  //Expanded(
                    SizedBox(
                      width: 300.0,
                      child: selectedImage.isEmpty
                          ? const Center(child: Text('Sorry nothing selected!!'))
                          : GridView.builder(
                              itemCount: selectedImage.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all()
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: kIsWeb
                                            ? Image.network(selectedImage[index].path)
                                            : Image.file(selectedImage[index])),
                                  ),
                                );
                              },
                            ),
                    )
                  //)
                  :
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all()
                    ),
                    child: InkWell(
                      onTap: () { _pilihSumber();},
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.search_normal),
                            Text('Tambahkan Foto', style: TextStyle(fontSize: 12))
                          ],
                        )
                      ),
                    )
                  )
                )
              ), 
              ),
              Padding(padding: const EdgeInsets.only(left: 50),
              child: Container(width: 150, height: 20, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),),
              ),
              const Padding(padding: EdgeInsets.only(left: 60),
              child: Text("Update Foto Pekerjaan", style: TextStyle(fontSize: 12),)
              )
            ],
          ),
          Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Container(
                height: 100,
                width: 370,
                decoration: BoxDecoration(
                  border: Border.all()
                ),
                child: Padding(padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: InkWell(
                      onTap: () {
                        proses3 ?
                          setState(() {
                            prosesIPS = !prosesIPS;
                            proses3 = !proses3;
                          })
                        : setState(() {
                          prosesIPS = !prosesIPS;
                        });
                      },
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: prosesIPS
                              ? Container(
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 0, 0, 0)),
                                )
                              : Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).scaffoldBackgroundColor),
                                )
                          ),
                      ),
                      )
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Proses IPS', style: TextStyle(fontSize: 12),),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: InkWell(
                        onTap: () {
                          prosesIPS
                          ?
                          setState(() {
                            proses3 = !proses3;
                            prosesIPS = !prosesIPS;
                          })
                          :
                          setState(() {
                            proses3 = !proses3;
                          });
                        },
                         child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: proses3
                                  ? Container(
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 0, 0, 0)),
                                    )
                                    
                                  : Container(
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).scaffoldBackgroundColor),
                                    )
                              ),
                          ),
                        ),
                      )
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left:8.0),
                      child: Text('Proses Pihak ke-3', style: TextStyle(fontSize: 12),),
                    )
                  ],
                )
                )
              ), 
              ),
              Padding(padding: const EdgeInsets.only(top: 10, left: 50),
              child: Container(width: 150, height: 30, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),),
              ),
              const Padding(padding: EdgeInsets.only(top: 12, left: 60),
              child: Text("Lanjutan Pekerjaan", style: TextStyle(fontSize: 12),)
              )
            ],
          ),
          selectedImage.isEmpty ?
          ElevatedButton(
            onPressed: () {
              _pilihSumber();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(144, 72, 111, 196)
            ), 
            child: const Text("Tambahkan Foto")
          ):
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            ElevatedButton(
              onPressed: () {
                _pilihSumber();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(144, 72, 111, 196)
              ), 
              child: const Text("Tambahkan Foto")
            ),
            ElevatedButton(
            onPressed: () {
              setState(() {
                selectedImage.clear();
                selectedImagePath.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(144, 72, 111, 196)
            ), 
            child: const Text("Hapus Foto")
          ),
          ]),
          Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                _tempDirectory = await getTemporaryDirectory();
                submintSPK();
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
              ), 
              child: const Text("Update SPK", style: TextStyle(color: Colors.black),),
            ),
          )
          ),
        ],
      )
    );
  }

  void _pilihSumber() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Pilih sumber gambar'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 8,
            child: Column(
              children: <Widget>[
                TextButton(
                  onPressed: (){
                    _pickImageFromGallery();
                    Navigator.of(context).pop();
                  }, 
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.image),
                      Text('Dari Galeri')
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    pickCameraImage();
                    Navigator.of(context).pop();
                  }, 
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.camera),
                      Text("Ambil Gambar")
                    ],
                  )
                )
              ],
            ),
          )
        );
      }
    );
  }

Future pickCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 10);

    if (pickedFile != null) {
      File fixedImage = await FlutterExifRotation.rotateAndSaveImage(path: pickedFile.path);
      setState(() {
        selectedImage.add(File(fixedImage.path));
        if (selectedImagePath.isNotEmpty) {
          selectedImagePath.insert(selectedImagePath.length - 1, fixedImage.path);
        } else {
          selectedImagePath.add(fixedImage.path);
        }
      });
    }
  }

  Future _pickImageFromGallery() async {
    final pickedFile = await picker.pickMultiImage(
      imageQuality: 60,
      maxHeight: 1000,
      maxWidth: 1000
    );
    List<XFile> xfilePick = pickedFile;

    if (xfilePick.isNotEmpty) {
      for (var i = 0; i < xfilePick.length; i++) {
        File fixedImage = await FlutterExifRotation.rotateAndSaveImage(path: xfilePick[i].path);
        selectedImage.add(File(fixedImage.path));
        if (selectedImagePath.isNotEmpty) {
          selectedImagePath.insert(selectedImagePath.length - 1, fixedImage.path);
        } else {
          selectedImagePath.add(fixedImage.path);
        }
      }
      setState(() { });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing Selected')));
      });
    }
  }

  Future getSign() async {
    
    var sign = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignForm())
    ); 
    

    //var file = await File('sign_image.jpg').writeAsBytes(data);
    //var filepath = File(file.path);
    //print(_tempDirectory);
    final tempPath = _tempDirectory!.path;
    File file = await File('$tempPath/signImage.png').create();
    file.writeAsBytesSync(sign);
    //selectedImage.add(file.path);
    setState(() {
      signImage = file;
      selectedImagePath.add(signImage!.path);
    });
  }

  Future<void> submintSPK() async {
    if (evaluasiSelesai.text.isEmpty || tindakanKerja.text.isEmpty) {
      return await warnAlert(text: 'Harus mengisi tindakan/evaluasi');
    }
     if (!prosesIPS && !proses3) {
      return await warnAlert(text: 'Harus memilih pihak penyelesai laporan');
    }

    loadingAlert('Proses Membuat SPK...');

    
    if (!spk) {
      await sendBuatSPK();
      if (spk) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
    
    loadingAlert('$_statusMessage\n${(_uploadProgress * 100).toStringAsFixed(0)}% Terunggah',);
    
    if (!uploaded) {
      selectedImage.add(signImage!);
      
      await _uploadMultipleImages();
      if (uploaded) {
        signImage = null;
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
        }
        await failAlert(text: "Gagal upload foto!");
      }
    }

    if (spk && uploaded) {
      if (await _tempDirectory!.exists()) {
        // recursive: true deletes all files and sub-folders inside
        await _tempDirectory!.delete(recursive: true);
      }
      await successAlert(text: 'SPK telah berhasil dibuat!');
      spk = false;
      uploaded = false;
    } else {
      await failAlert(text: 'Cek koneksi dan submit ulang!');
    }
  }

  Future<void> _uploadMultipleImages() async {
    if (selectedImage.isEmpty) return;

    String uploadUrl = 'https://ipsrsslg.my.id/ipscrud/upload_image.php'; 
    Dio dio = Dio();

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _statusMessage = "Mengunggah ${selectedImage.length} gambar...";
    });

    try {
      FormData formData = FormData.fromMap({
        "ttd" : "none",
        "jenis" : "laporan",
        "status" : "proses",
        "nospk" : widget.dataproses.nomorspk,
      });

      // Looping untuk menambahkan setiap file ke dalam FormData
      // Gunakan key 'files[]' agar dibaca sebagai array oleh backend PHP
      for (File file in selectedImage) {
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            "files[]",
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }


      // Kirim data menggunakan metode POST
      Response response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (total != -1) {
            setState(() {
              _uploadProgress = sent / total; // Mengalkulasi progress total semua file
            });
          }
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Sukses: ${response.data['message']}";
          selectedImage.clear(); // Bersihkan list jika berhasil
          uploaded = true;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.message}";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

Future<void> successAlert({String text = ''}) {
    return QuickAlert.show(
      onConfirmBtnTap: () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
          builder: (context) => const Tab2masuk()), (Route route) => false);
      },
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  Future<void> failAlert({String text = ''}) {
    return QuickAlert.show(
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        setState(() {});
      },
      context: context,
      type: QuickAlertType.error,
      text: text,
    );
  }

  Future<void> warnAlert({String text = ''}) {
    return QuickAlert.show(
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
      context: context,
      type: QuickAlertType.warning,
      text: text,
    );
  }


  Future <void> loadingAlert(String text) {
    return QuickAlert.show(
      barrierDismissible: false,
      context: context,
      type: QuickAlertType.loading,
      widget: StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          // Simulating a background task that modifies the text
          Future.delayed(Duration(milliseconds: 500), () {
            if (_isUploading) {
              // 3. Trigger the dialog-specific StateSetter
              dialogSetState(() {
                text = '$_statusMessage\n${(_uploadProgress * 100).toStringAsFixed(0)}% Terunggah';
              });
            }
          });

          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }



  Widget showLoading() {
      return Center(
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
          child: Center(
            child: CircularProgressIndicator(color: Colors.white,),
          ),
        ),
      );
    }
  
}

class HttpUploadService {
  
  Future<String> uploadPhotos(List<String> paths) async {
    String fotottd = "none";
    // if (sumberpekerjaan == "Inspeksi"){
    //   fotottd = "none";
    // } else{
    //   fotottd = "yes";
    // }
    var respon ='';
    Uri uri = Uri.parse('https://ipsrsslg.my.id/ipscrud/upload_image_proses_update.php?nospk=$noSPK&ttd=$fotottd');
    http.MultipartRequest request = http.MultipartRequest('POST', uri);


    
    for(String path in paths){
      request.files.add(await http.MultipartFile.fromPath('files[]', path));
    }
    //request.fields['bidang'] = bidang!;
    try {
      http.StreamedResponse response = await request.send().timeout(
        const Duration(seconds: 10),
      );
      final respons = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        //var responseBytes = await response.stream.bytesToString();
        respon = respons.body;
      }
    } on TimeoutException catch(_) {
      respon = 'Timeout';
    } catch (e) {
      respon = '$e';
    }
    return respon;
  }
}