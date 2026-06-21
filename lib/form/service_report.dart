import 'dart:async';
import 'dart:io';
import 'package:acslg/form/sign/signature.dart';
import 'package:acslg/pekerjaan/masuk/tab_3.dart';
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

String noSPK = '';

class _UpdateSPKFormState extends State<UpdateSPKForm> {
  
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  String _statusMessage = "";
  
  bool spk = false;
  bool uploaded = false;
 
  Directory ? _tempDirectory;
  File ? signImage;
  Uint8List ? signShow;
  List<File> selectedImage = [];
  List<File> selectedShowImage = [];
  List<String> selectedImagePath = [];
  final picker = ImagePicker();

  final TextEditingController teknisi = TextEditingController();

  final TextEditingController tekanan = TextEditingController();
  final TextEditingController arus = TextEditingController();
  final TextEditingController suhuIn = TextEditingController();
  final TextEditingController suhuOut = TextEditingController();

  final TextEditingController gejala = TextEditingController();
  final TextEditingController penyebab = TextEditingController();
  final TextEditingController tindakan = TextEditingController();
  final TextEditingController evaluasi = TextEditingController();
  final TextEditingController rekomendasi = TextEditingController();

  Future sendBuatSPK() async {
    DateTime now = DateTime.now();
    String bulan = DateFormat('MM').format(now); //Bulan Sekarang
    if (int.parse(bulan) < 10) {
    } else{
    }
     
    String tahun = DateFormat('yyyy').format(now); // Tahun Sekarang
    tahun.substring(2, 4);
    String uri = "https://ipsrsslg.my.id/ipscrud/p3AC/updatePekerjaanP3.php";

    try {
      final response = await http.post(Uri.parse(uri), body: {
        'jenis' : 'verifikasi',
        'nolap' : widget.datalapsend.nomor,
        'nospk' : widget.dataproses.nomorspk,
        'kode' : widget.dataproses.kodealat,
        'tekanan' : tekanan.text,
        'arus' : arus.text,
        'suhuIn' : suhuIn.text,
        'suhuOut' : suhuOut.text,
        'gejala' : gejala.text,
        'penyebab' : penyebab.text,
        'tindakan' : tindakan.text,
        'evaluasi' : evaluasi.text,
        'rekomendasi' : rekomendasi.text,
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
          title: Text('SERVICE REPORT',
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
    var sx = MediaQuery.of(context).size.width;
    var sy = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: sx*0.9,
            child: Padding(padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all()
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.dataproses.kodealat, style: Theme.of(context).textTheme.headlineSmall),
                    )
                  ),
                ),
                SizedBox(height: sy*0.02),
                Text("A. Pemeriksaan Teknis & Pengukuran", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: sy*0.01),
                Padding(
                  padding: EdgeInsets.only(left: sx*0.04, right: sx*0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: sx*0.35, child: Text("Tekanan Freon (Psi)")),
                          SizedBox(width: sx*0.05, child: Text(":")),
                          SizedBox(
                            width: sx*0.1,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              controller: tekanan,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: sy*0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: sx*0.35, child: Text("Arus (A)")),
                          SizedBox(width: sx*0.05, child: Text(":")),
                          SizedBox(
                            width: sx*0.1,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              controller: arus,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: sy*0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: sx*0.35, child: Text("Suhu In (°)")),
                          SizedBox(width: sx*0.05, child: Text(":")),
                          SizedBox(
                            width: sx*0.1,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              controller: suhuIn,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: sy*0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: sx*0.35, child: Text("Suhu Out (°)")),
                          SizedBox(width: sx*0.05, child: Text(":")),
                          SizedBox(
                            width: sx*0.1,
                            child: TextField(
                              style: TextStyle(fontSize: 14),
                              controller: suhuOut,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sy*0.02),
                Text("B. Analisa Sistem & Tindakan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: sy*0.01),
                TextField(
                  maxLines: null,
                  style: TextStyle(fontSize: 12),
                  controller: gejala,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    hintText: "Masukkan keluhan/gejala kerusakan AC"
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(fontSize: 12),
                    controller: penyebab,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      hintText: "Masukkan hasil analisa penyebab kerusakan"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(fontSize: 12),
                    controller: tindakan,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      hintText: "Masukkan tindakan yang dilakukan untuk perbaikan"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(fontSize: 12),
                    controller: evaluasi,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      hintText: "Masukkan kondisi AC setelah selesai perbaikan dan observasi"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(fontSize: 12),
                    controller: rekomendasi,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      hintText: "Masukkan rekomendasi untuk user/teknisi pemelihara"
                    ),
                  ),
                ),
                SizedBox(height: sy*0.02),
                Text("C. Dokumentasi Sebelum/Sesudah Perbaikan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: sy*0.01),
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
                        selectedShowImage.isNotEmpty ?
                        //Expanded(
                          SizedBox(
                            width: 300.0,
                            child: selectedShowImage.isEmpty
                                ? const Center(child: Text('Sorry nothing selected!!'))
                                : GridView.builder(
                                    itemCount: selectedShowImage.length,
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
                                                  ? Image.network(selectedShowImage[index].path)
                                                  : Image.file(selectedShowImage[index])),
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
                  ],
                ),
              ],
            )
            )
          ),
          selectedShowImage.isEmpty ?
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
                selectedShowImage.clear();
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
                if (await userKonfirm()) {
                  submintSPK();
                }
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
              ), 
              child: const Text("Kirim Service Report", style: TextStyle(color: Colors.black),),
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
        selectedImage.insert(0, File(fixedImage.path));
        selectedShowImage.add(File(fixedImage.path));
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
        selectedImage.insert(0, File(fixedImage.path));
        selectedShowImage.add(File(fixedImage.path));
      }
      setState(() { });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing Selected')));
      });
    }
  }

  Future <void> getSign() async {
    var sign = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignForm())
    ); 

    _tempDirectory = await getTemporaryDirectory();

    final tempPath = _tempDirectory!.path;
    File file = await File('$tempPath/signImage.png').create();
    file.writeAsBytesSync(sign);
    setState(() {
      signImage = file;
      signShow = File(file.path).readAsBytesSync();
      selectedImage.add(file);
    });
    
  }

  Future<bool> userKonfirm() async{
    final bool? dynamicResult = await showDialog<bool>(
    context: context, 
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, setStateB) {
            return AlertDialog(
            //title: const Center(child: Text('Konfirmasi User')),
            content: Container(
              decoration: BoxDecoration(
                color: Colors.grey
              ),
              width: 200,
              height: 200,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              TextField(
                controller: teknisi,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  contentPadding: const EdgeInsets.all(5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  hintText: "User/Penerima Pekerjaan"
                )
              ),
              //widget.datalapsend.sumber == "Ruangan" ?
              Padding(
                padding: const EdgeInsets.all(8.0),
                child :
                    signImage != null
                    ? Container(
                      height: 130,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Image(image: MemoryImage(signShow!)))
                    :
                      InkWell(
                        onTap: () async {
                          await getSign();
                          setStateB((){});
                        },
                        child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all()
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.pen_add),
                              Text('Tambahkan TTD')
                            ],
                          ),
                        )
                      ),
                    ),
                  )//:SizedBox()
                ]
              ),
            ),
            actions: <Widget>[
              TextButton(onPressed: () async {
                Navigator.pop(context, true);
              }, style: TextButton.styleFrom(backgroundColor: Colors.yellowAccent), child: const Text('Konfirmasi'))
            ],
          );
        }
      );
      }
    );
    if (dynamicResult == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> submintSPK() async {

    if (tekanan.text.isEmpty || arus.text.isEmpty || suhuIn.text.isEmpty ||
        suhuOut.text.isEmpty || gejala.text.isEmpty || penyebab.text.isEmpty || 
        tindakan.text.isEmpty || evaluasi.text.isEmpty || rekomendasi.text.isEmpty) 
    {
      return await warnAlert(text: 'Harus mengisi lengkap seluruh data');
    }

    if (selectedImage.isEmpty || selectedImage.length < 2) {
      return await warnAlert(text: 'Pilih minim 2 foto');
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
      await successAlert(text: 'Service report berhasil dikirim!');
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
        "ttd" : "yes",
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
          builder: (context) => const Tab3masuk()), (Route route) => false);
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