//import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:image_picker/image_picker.dart';

Future<void> adicionaProduto(
  String nome,
  double preco,
  String descricao,
  int quantidade,
  //List<XFile> imagens, // <- até 3 imagens
) async {
  /*if (imagens.length > 3) {
    throw Exception("Você só pode enviar até 3 imagens.");
  }

  List<String> imageUrls = [];

  for (var i = 0; i < imagens.length; i++) {
    final XFile imagem = imagens[i];
    final String nomeArquivo =
        '${DateTime.now().millisecondsSinceEpoch}_${imagem.name}';

    final ref = FirebaseStorage.instance
        .ref()
        .child('produtos')
        .child(nomeArquivo);

    print('Upload de imagem: ${imagem.path}');
    await ref.putFile(File(imagem.path));
    final url = await ref.getDownloadURL();

    imageUrls.add(url);
  }*/

  await FirebaseFirestore.instance.collection('produtos').add({
    'nome': nome,
    'preco': preco,
    'descricao': descricao,
    'quantidade': quantidade,
    //'imagens': imageUrls,
    'criadoEm': Timestamp.now(),
  });
}
