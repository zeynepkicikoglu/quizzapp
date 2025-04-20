import 'soru.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestVeri {
  int _soruIndex = 0;

  Future<List<Soru>> fetchQuestionsFromFirestore() async {
    print("Sorular Firestore'dan çekiliyor...");
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('questions').get();

      List<Soru> sorular = snapshot.docs.map((doc) {
        return Soru(
          soruMetni: doc.data()['question'] ?? "Bilinmeyen Soru",
          soruYaniti: doc.data()['correctAnswer'] ?? false,
        );
      }).toList();

      print("Firestore'dan gelen sorular: $sorular");
      return sorular;
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  void testisifirla() {
    _soruIndex = 0;
  }
}

void uploadQuestionsToFirestore(List<Soru> soruBankasi) async {
  for (var soru in soruBankasi) {
    await FirebaseFirestore.instance.collection('questions').add({
      'question': soru.soruMetni,
      'correctAnswer': soru.soruYaniti,
    });
  }
  print('Sorular Firebase Firestore\'a yüklendi!');
}
