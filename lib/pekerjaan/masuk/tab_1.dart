import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:convert';

import 'package:quickalert/widgets/quickalert_dialog.dart';


class DataLaporanParse {
  final String id, tanggal, nama, ruangan, laporan, sumber, jenislaporan, nomor, nomorlaporan, status, statusProses;

  const DataLaporanParse(this.id, this.tanggal, this.nama, this.ruangan, this.laporan, this.sumber, this.jenislaporan, this.nomor, this.nomorlaporan, this.status, this.statusProses);
}

class Tab1masuk extends StatefulWidget {
  const Tab1masuk({super.key});

  @override
  State<StatefulWidget> createState() => _Tab1Menu();
}

String nomorSPK = '';
String ket = '';
String rekom = '';
String tanggalproses = '';

String ? bidang;
String ? ruang;
String ? jenislap;

class _Tab1Menu extends State<Tab1masuk> {
  final TextEditingController namaPelaporController = TextEditingController();
  final TextEditingController detailLaporanController = TextEditingController();
  final TextEditingController searchLaporan = TextEditingController();
  bool isLoading = false;
  bool data = false;
  int result = 0;
  final List<ProsesDetail> _searchResult = [];
  List<ProsesDetail> listLaporan  = [];


  //spk PROSES DETAIL
  List<Progres> listProses = [];
  String ? selectedDetail;
  bool spk = false;
  bool proses = false;

  TextEditingController alasanTolak = TextEditingController();

  bool garansi = false;
  bool permintaanKlaim = false;
  
  Future refresh () async {
    _searchResult.clear();
    listLaporan.clear();
    listProses.clear();
    proses = false;
    await getAllLaporan();
    setState(() {});
  }
  

  
  Future<void> getAllLaporan() async{
    String uri = "https://ipsrsslg.my.id/ipscrud/p3AC/laporanP3.php?status=masuk";
    final response = await http.get(Uri.parse(uri));
    final responseJson = json.decode(response.body);
    if (responseJson != 0) {
      setState(() {
        for (Map data in responseJson) {
          listLaporan.add(ProsesDetail.fromJson(data));
        }
        data = true;
      });
    } else {
      setState(() {
        data = true;
      });
    }
  }

  Future<void> getSPKProses() async{
    String uri = "https://ipsrsslg.my.id/ipscrud/getSPK.php?status=Proses";

    final response = await http.post(Uri.parse(uri), body: {
      'nomor': selectedDetail,
    });
 
    if (response.body == '0') {
      return await presentAlert(
        title: 'Error',
        message: 'Error saat pengambilan database'
      );
    } else {
      final responseJson = json.decode(response.body);
      if (responseJson != 0) {
        setState(() {
        for (Map data in responseJson) {
          spk = true;
          listProses.add(Progres.fromJson(data));
        }
      });
      }
    } 
  }

  Future prosesPekerjaanP3(nolap) async {
    dynamic loadingcontext;

    QuickAlert.show(
      barrierDismissible: false,
      context: context,
      type: QuickAlertType.loading,
      widget: StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          loadingcontext = context;
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Memproses laporan...",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );

 

    if (permintaanKlaim && !garansi) {
      if (alasanTolak.text.isEmpty) {
        return await warnAlert(text: 'Harus mengisi alasan menolak permintaan garansi!');
      }
    }
    

    String uri = "https://ipsrsslg.my.id/ipscrud/p3AC/updatePekerjaanP3.php";
    
    try {
      final response = await http.post(Uri.parse(uri), body: {
        'jenis' : 'proses',
        'nolap' : nolap,
        'garansi' : garansi.toString(),
        'klaim' : permintaanKlaim.toString(),
        'alasan' : alasanTolak.text,
      }).timeout(Duration(seconds: 10), onTimeout: (){ return http.Response('Error: Timeout', 408); });
      
      if (response.statusCode == 200) {
        if (response.body == '1'){
          garansi = false;
          permintaanKlaim = false;
          alasanTolak.text = '';
          proses = true;  
          Navigator.of(loadingcontext).pop();
          await successAlert(text: 'Laporan berhasil diproses!');
        }
      } 
      
    } on TimeoutException catch(_) { 
      return await failAlert(text: 'Connection Timeout!');
    } catch (e) {
      await failAlert(text: '$e');
    }
  }


  Future<void> ambilData () async {
    setState(() {
      isLoading = true;
    });
    await getAllLaporan();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    namaPelaporController.dispose();
    detailLaporanController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!data) {
      ambilData();
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.15),
                    blurRadius: 40,
                    spreadRadius: 0.8,
                  )
                ]
              ),
              child: TextField(
                controller: searchLaporan,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  contentPadding: const EdgeInsets.all(5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  prefixIcon: const Icon(Iconsax.search_normal),
                ),
                onChanged: onSearchTextChanged,
              ),
            ),
          ),
        ),
        body: listLaporan.isEmpty
        ? isLoading ? showLoading() : Center(child: Text('Tidak ada laporan proses'))
        :
        searchLaporan.text.isNotEmpty
        ? cariLaporan()
        :
        oriLaporan()
      ),
    );
  }

  ListView cariLaporan() {
    return ListView.builder(
    itemCount: _searchResult.length,
    itemBuilder: (BuildContext context, int index) => Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: 
        InkWell(
          onTap: () async {
            if (listProses.isNotEmpty){
                listProses.clear();
              }
            spk = false;
            selectedDetail = _searchResult[index].nomor;
            await getSPKProses();
            if (spk) {
              nomorSPK = listProses[0].nomorspk;
              ket = listProses[0].tindakan;
              rekom = listProses[0].keterangan; 
              tanggalproses = listProses[0].tanggal;
              _konfirmLaporan(index.toString(), _searchResult, listProses);
            }
          },
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
            ),
            child: 
              Stack(
                fit: StackFit.loose,
                children: [
                  Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      color: Color.fromARGB(255, 54, 53, 51),
                      child: 
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
                                    child: 
                                    Text('${_searchResult[index].nama} :', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),)
                                  ),
                                  Text(_searchResult[index].ruangan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                                ]
                              )
                            ),
                          ],
                          ),
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 15),
                        width: MediaQuery.of(context).size.width*0.75,
                        child:
                        Text(_searchResult[index].laporan, style: const TextStyle(fontSize: 12),) 
                      ),
                  ],
                ),
                if (_searchResult[index].jenislaporan == 'AC' && _searchResult[index].garansi == '1')
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width*0.75),
                        SizedBox(
                          child: Image.asset( 
                            'assets/garansi_klaim.png',
                            width: MediaQuery.of(context).size.width*0.15,
                            height: MediaQuery.of(context).size.width*0.15,
                            fit: BoxFit.cover, // Controls how the image fills its bounding box
                          )
                        )
                      ],
                    ),
                  ],
                )
                ]
              ),
          ),
        ),
    )
    );
  }

  ListView oriLaporan() {
    return ListView.builder(
      itemCount: listLaporan.length,
      itemBuilder: (BuildContext context, int index) => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: 
          InkWell(
            onTap: () async {
              if (listProses.isNotEmpty){
                listProses.clear();
              }
              spk = false;
              selectedDetail = listLaporan[index].nomor;
              await getSPKProses();
              if (spk) {
                nomorSPK = listProses[0].nomorspk;
                ket = listProses[0].tindakan;
                rekom = listProses[0].keterangan; 
                tanggalproses = listProses[0].tanggal;
                _konfirmLaporan(index.toString(), listLaporan, listProses);
              }
            },
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
              ),
              child: 
                Stack(
                  fit: StackFit.loose,
                  children: [ 
                    Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color:Color.fromARGB(255, 54, 53, 51),
                        child: 
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
                                      child: 
                                      Text('${listLaporan[index].nama} :', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),)
                                    ),
                                    Text(listLaporan[index].ruangan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                                    ]
                                  )
                                ),
                              ],
                            ),
                          ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 15),
                        width: MediaQuery.of(context).size.width*0.75,
                        child:
                        Text(listLaporan[index].laporan, style: const TextStyle(fontSize: 12),) 
                      ),
                    ],
                  ),
                  if (listLaporan[index].jenislaporan == 'AC' && listLaporan[index].garansi == '1')
                  Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width*0.75),
                          SizedBox(
                            child: Image.asset(
                              'assets/garansi_klaim.png',
                              width: MediaQuery.of(context).size.width*0.15,
                              height: MediaQuery.of(context).size.width*0.15,
                              fit: BoxFit.cover, // Controls how the image fills its bounding box
                            )
                          )
                        ],
                      ),
                    ],
                  )
                  ],
                ),
            ),
          ),
      )
      );
  }

  Future <void> _konfirmLaporan (index, datalaporan, detailproses) {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Center(child: Text('Konfirmasi Laporan \nProses', textAlign: TextAlign.center)),
          content:  
           SingleChildScrollView(
             child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(20)
              ),
              //height: 300,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(child: Text('DATA LAPORAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                    SizedBox(height: MediaQuery.of(context).size.height/50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25, width: 100, child:  Text('Kode AC')),
                        SizedBox(height: 25, width: 100, child: Text(': ${detailproses[0].kodealat}')),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25, width: 100, child: Text('Tgl. Masuk')),
                        SizedBox(height: 25, width: 100, child: Text(': ${DateFormat('dd/MM/yyy').format(DateTime.parse(tanggalproses))}')),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25, width: 100, child: Text('Nomor SPK')),
                        spk ?
                        SizedBox(height: 25, width: 100, child: Text(': $nomorSPK'))
                        :
                        const SizedBox(height: 25, width: 100, child: Text(': Error302'))
                      ],
                    ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25, width: 100, child: Text('Kategori')),
                        SizedBox(height: 25, width: 120, child: Text(': ${datalaporan[int.parse(index)].jenislaporan}')),
                      ],
                    ),*/
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 25, width: 100, child: Text('Tindakan IPS')),
                        SizedBox(height: 25, width: 120, child: Text(':')),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(ket, textAlign: TextAlign.left,),
                      ),
                    ),
                    if (rekom != "")
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 25, width: 100, child: Text('Keterangan')),
                        SizedBox(height: 25, width: 120, child: Text(':')),
                      ],
                    ),
                    if (rekom != "")
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(rekom, textAlign: TextAlign.left,),
                      ),
                    ),
                    if (datalaporan[int.parse(index)].jenislaporan == "AC" && datalaporan[int.parse(index)].garansi == "1")
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 25, width: 100, child: Text('Status')),
                            SizedBox(height: 25, width: 10, child: Text(':')),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Menuggu Keputusan Garansi'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
               ),
             ),
           ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const BackButton(
                color: Colors.black,
              ),
              const SizedBox(
                width: 20,
              ),
              datalaporan[int.parse(index)].jenislaporan == "AC" && datalaporan[int.parse(index)].garansi == "1" ?
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0)
                    ),
                    onPressed: () async {
                      garansi = true;
                      permintaanKlaim = true;
                      Navigator.of(context).pop();
                      await prosesPekerjaanP3(datalaporan[int.parse(index)].nomor);
                      refresh();
                    }, 
                    child: const Text('Terima Garansi & Proses', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      backgroundColor: const Color.fromARGB(255, 236, 79, 79)
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      tolakGaransi(datalaporan[int.parse(index)].nomor);
                    }, 
                    child: const Text('Tolak Garansi', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
                  ),
                ],
              )
              :
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0)
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await prosesPekerjaanP3(datalaporan[int.parse(index)].nomor);
                  refresh();
                }, 
                child: const Text('Proses Laporan', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
              ),
              ]
            )
          ],
        );
      }
    );
  }

  Future<void> tolakGaransi(nolap) async{
    return showDialog(
    context: context, 
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, setStateB) {
            return AlertDialog(
            //title: const Center(child: Text('Konfirmasi User')),
            content: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Tolak Garansi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 5),
                      TextField(
                        maxLines: null,
                        controller: alasanTolak,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.all(5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: "isi alasan menolak permintaan garansi"
                        )
                      ),
                    ]
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(onPressed: () async {
                  permintaanKlaim = true;
                  Navigator.of(context).pop();
                  await prosesPekerjaanP3(nolap);
                  refresh();
                }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Konfirmasi', style: TextStyle(color: Colors.black),)),
              )
            ],
          );
        }
      );
    }
    );
  }

  Future<void> presentAlert(
      {String title = '', String message = '', Function()? ok}) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(message)
              ],
            ),
          );
        });
    }



  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return; 
    }
    setState(() {});
  }

  Future<void> successAlert({String text = ''}) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: text,
    );
  }

  Future<void> failAlert({String text = ''}) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: text,
    );
  }

  Future<void> warnAlert({String text = ''}) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: text,
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

class Progres {
  final String id, tanggal, alat, nomorspk, teknisi1, teknisi2, teknisi3, teknisi4, tindakan, keterangan, kodealat;

  Progres({required this.id, required this.tanggal, required this.nomorspk, required this.alat, required this.teknisi1, required this.teknisi2, required this.teknisi3, required this.teknisi4, required this.tindakan, required this.keterangan, required this.kodealat});

  factory Progres.fromJson(Map<dynamic, dynamic> json) {
    return Progres(
      id: json['id'],
      tanggal: json['tanggal'],
      nomorspk: json['nospk'],
      alat: json['alat'],
      teknisi1: json['teknisi1'],
      teknisi2: json['teknisi2'],
      teknisi3: json['teknisi3'],
      teknisi4: json['teknisi4'],
      tindakan: json['tindakan'],
      keterangan: json['keterangan'],
      kodealat: json['kodeUtilitas']
    );
  }
  @override
  String toString() => "{id : $id, tanggal: $tanggal, nomorspk: $nomorspk, alat: $alat, teknisi1: $teknisi1, teknisi2: $teknisi2, teknisi3: $teknisi3, teknisi4: $teknisi4, tindakan: $tindakan, keterangan: $keterangan, kodealat: $kodealat}";
}



class ProsesDetail {
  final String id, tanggal, nama, ruangan, laporan, sumber, jenislaporan, nomor, nomorlaporan, status, statusProses, statusp3, garansi;

  ProsesDetail({required this.id, required this.tanggal, required this.nomor, required this.nama, required this.ruangan, required this.laporan, required this.jenislaporan, required this.sumber, required this.status, required this.nomorlaporan, required this.statusProses, required this.statusp3, required this.garansi});

  factory ProsesDetail.fromJson(Map<dynamic, dynamic> json) {
    return ProsesDetail(
      id: json['id'],
      tanggal: json['tanggal'],
      nomor: json['nomor'],
      nama: json['nama'],
      ruangan: json['ruangan'],
      laporan: json['laporan'],
      sumber: json['sumber'],
      jenislaporan: json['jenislaporan'],
      status: json['status'],
      nomorlaporan: json['nomorlaporan'],
      statusProses: json['statusProses'],
      statusp3: json['statusp3'],
      garansi: json['garansi'],
    );
  }
  @override
  String toString() => "{id : $id, tanggal: $tanggal, nomor: $nomor, nama: $nama, ruangan: $ruangan, laporan: $laporan, sumber:$sumber, jenis: $jenislaporan, status: $status, nomorlaporan: $nomorlaporan, statusProses: $statusProses, statusp3: $statusp3, garansi: $garansi";
}




