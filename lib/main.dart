import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yarisma/test_veri.dart';
import 'constants.dart';
import 'soru.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlatıyoruz
  await Firebase.initializeApp();

  runApp(const BilgiTesti());
}

class BilgiTesti extends StatelessWidget {
  const BilgiTesti({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.indigo[700],
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SoruSayfasi(),
            ))));
  }
}

class SoruSayfasi extends StatefulWidget {
  const SoruSayfasi({super.key});

  @override
  _SoruSayfasiState createState() => _SoruSayfasiState();
}

class _SoruSayfasiState extends State<SoruSayfasi> {
  List<Widget> secimler = [];
  int _soruIndex = 0;
  int dogruSayisi = 0;
  int yanlisSayisi = 0;
  List<Soru> soruBankasi = [];
  TestVeri testVeri = TestVeri(); // TestVeri sınıfının bir örneği

  @override
  void initState() {
    super.initState();
    print("Sorular Firestore'dan çekiliyor...");
    testVeri.fetchQuestionsFromFirestore().then((data) {
      setState(() {
        soruBankasi = data;
      });
      print("Firestore'dan gelen sorular: $soruBankasi");
    }).catchError((e) {
      print("Firestore'dan veri çekerken hata oluştu: $e");
    });
  }

  void butonFonksiyonu(bool secilenbuton) {
    if (_soruIndex + 1 >= soruBankasi.length) {
      Widget okButton = TextButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {
            _soruIndex = 0;
            secimler = [];
            dogruSayisi = 0;
            yanlisSayisi = 0;
          });
        },
      );

      String baslik = dogruSayisi >= yanlisSayisi ? "TEBRİKLER!" : "ÜZGÜNÜZ!";
      String mesaj = dogruSayisi >= yanlisSayisi
          ? "TESTİ BİTİRDİNİZ!\n\nDoğru Sayısı: $dogruSayisi\nYanlış Sayısı: $yanlisSayisi"
          : "TEST TAMAMLANDI!\n\nDoğru Sayısı: $dogruSayisi\nYanlış Sayısı: $yanlisSayisi\nBir dahaki sefere daha iyi olabilirsiniz!";

      AlertDialog alert = AlertDialog(
        title: Text(
          baslik,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
        content: Text(mesaj),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {
        if (soruBankasi[_soruIndex].soruYaniti == secilenbuton) {
          secimler.add(kDogruIconu);
          dogruSayisi++;
        } else {
          secimler.add(kYanlisIconu);
          yanlisSayisi++;
        }

        _soruIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'BİLGİ YARISMASI\n'
          'HOSGELDİNİZ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                soruBankasi.isEmpty
                    ? "Sorular Yükleniyor..."
                    : soruBankasi[_soruIndex].soruMetni,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Wrap(spacing: 3, runSpacing: 3, children: secimler),
        Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(children: <Widget>[
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: soruBankasi.isEmpty
                              ? null
                              : () {
                                  butonFonksiyonu(false);
                                },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.thumb_down, size: 30.0),
                          ),
                        ))),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: soruBankasi.isEmpty
                              ? null
                              : () {
                                  butonFonksiyonu(true);
                                },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.thumb_up, size: 30.0),
                          ),
                        ))),
              ])),
        )
      ],
    );
  }
}
