import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sballando/api/sb_api_user.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_input.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/components/sb_switch.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

class SbUserEdit extends StatefulWidget {
  const SbUserEdit({super.key});

  @override
  State<SbUserEdit> createState() => SbUserEditState();
}

class SbUserEditState extends State<SbUserEdit> {

  final                             keyForm                             = GlobalKey<FormState>();


  final TextEditingController       nameController                      = TextEditingController();
  final TextEditingController       surnameController                   = TextEditingController();
  final TextEditingController       nicknameController                  = TextEditingController();
  final TextEditingController       bioController                       = TextEditingController();
  final TextEditingController       phoneController                     = TextEditingController();
  final TextEditingController       emailController                     = TextEditingController();
  final TextEditingController       birthdateController                 = TextEditingController();
  final TextEditingController       instagramController                 = TextEditingController();
  final TextEditingController       tiktokController                    = TextEditingController();
  final TextEditingController       whatsappController                  = TextEditingController();


  DateTime?                         selectedDate;
  String?                           prefixValue;
  String?                           regioneValue;
  String?                           provinciaValue;

  List<String>                      prefixList                          = [];
  List<String>                      provinceList                        = [];
  List<String>                      regioniList                         = [];

  String                            errorMessage                        = '';
  String                            userNickname                        = '';
  Map                               user                                = {};

  bool                              _isModalOpen                        = false;
  bool                              showError                           = false;
  bool                              acceptedPolicy                      = true;
  bool                              loader                              = true;
  bool                              vibration                           = false;
  bool                              ringtone                            = false;
  bool                              visibility                          = false;
  File?                             _image;




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      final args        = ModalRoute.of(context)!.settings.arguments as Map;
      if (args.isNotEmpty) {
        userNickname            = args['nickname'] ?? USER['id'];
        dynamic data            = await ApiUser().getUser(userNickname);
        dynamic prefixData      = await ApiUser().getPhoneCodes();
        dynamic regioniData     = await ApiUser().getRegioni();

        if(regioniData != null){
          regioniData.forEach((regione){
            regioniList.add(regione['regione']);
          });
        }

        if(prefixData != null && prefixData['status'] != false){
          if(prefixData['phoneCodes'] != null){
            prefixData['phoneCodes'].forEach((pref){
              prefixList.add(pref['dial_code']);
            });
          }
        }

        if(data != null && data['user'] != null){
          loader                              = false;
          user                                = data['user'];

          nameController.text                 = user['name'] ?? '';
          surnameController.text              = user['surname'] ?? '';
          bioController.text                  = user['bio'] ?? '';
          nicknameController.text             = user['nickname'] ?? '';
          instagramController.text            = user['link_instagram'] ?? '';
          tiktokController.text               = user['link_tiktok'] ?? '';

          // birthdateController.text            = user['birthday'] ?? '';
          emailController.text                = user['email'] ?? '';
          phoneController.text                = user['phone'] ?? '';
          regioneValue                        = user['region'];
          if(regioneValue != null){
            List<String> provinceData = await ApiUser().getProvince(regioneValue!);
            if(provinceData.isNotEmpty){
              provinceList = provinceData;
            }
          }


          provinciaValue                      = user['city'];
          prefixValue                         = user['prefix_phone'];
          acceptedPolicy                      = await getShared('bool', 'policy') ?? false;
          vibration                           = await getShared('bool', 'vibration') ?? false;
          ringtone                            = await getShared('bool', 'ringtone') ?? false;
          visibility                          = user['visibility'] == 1 ? true : false;
        }
        
        
      }
      loader = false;
      if(mounted){
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _checkPermissions() async {
    await [
      Permission.camera,
      Permission.photos, // per iOS
      Permission.storage, // per Android
    ].request();
  }
  // Funzione per selezionare l'immagine dalla galleria o scattare una foto
  Future<void> _pickImage(ImageSource source) async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // File? croppedFile = await _cropImage(File(pickedFile.path));
      // if (croppedFile != null) {
      //if(mounted){
        _image = File(pickedFile.path);
        setState(() {
          
        });
      //}
      // }
    }
  } catch (e) {

    // Se vuoi, mostra anche un alert all’utente
  }
}

// Future<File?> _cropImage(File imageFile) async {
//   try {
//     CroppedFile? cropped = await ImageCropper().cropImage(
//       sourcePath: imageFile.path,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Ritaglia Immagine',
//           toolbarColor: mainColor,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(
//           title: 'Ritaglia Immagine',
//         ),
//       ],
//     );

//     if (cropped != null) {
//       return File(cropped.path);
//     } else {
//       return null;
//     }
//   } catch (e, stacktrace) {
//     print('Errore _cropImage: $e');
//     print(stacktrace);
//     return null;
//   }
// }

  // Funzione per mostrare la scelta Galleria/Fotocamera
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galleria'),
              onTap: () async{
                Navigator.of(context).pop();
                await _checkPermissions();
                await _pickImage(ImageSource.gallery); 
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Scatta Foto'),
              onTap: () async{
                Navigator.of(context).pop();
                await _checkPermissions();
                await _pickImage(ImageSource.camera); 
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(loader == true)
              Center(
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    color: mainColor,
                    strokeWidth: 10, // Spessore della linea dello spinner
                  ),
                ),
              ),
              if(loader == false)
              Form(
              key: keyForm,
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    
                    SizedBox(height: 80,),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none, // permette all'immagine di uscire dal Container
                        alignment: Alignment.topCenter, // centra orizzontalmente
                        children: [
                          Container(
                            width: width(context, 90),
                            padding: EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 30), // spazio per lasciare la foto sopra
                                Row(
                                  children: [
                                    Expanded(
                                      child: SbInputUnderline(
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: textMidHight,
                                        ),
                                        positionText: 'right',
                                        controller: nameController,
                                        obscureText: false,
                                        label: 'Name',
                                        validatorFunction: (value) {
                                          String error = '';
                                          if(error == ''){
                                            error =  validatorRequired(value!);
                                          }
                                  
                                          if(error == ''){
                                            error =  validatorLenght(value!,3,40);
                                          }
                                          
                                          if(error != ''){
                                            return error;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10), // spazio tra i due input
                                    Expanded(
                                      child: SbInputUnderline(
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: textMidHight,
                                        ),
                                        positionText: 'left',
                                        controller: surnameController,
                                        obscureText: false,
                                        label: 'Surname',
                                        validatorFunction: (value) {
                                          String error = '';
                                          if(error == ''){
                                            error =  validatorRequired(value!);
                                          }
                                  
                                          if(error == ''){
                                            error =  validatorLenght(value!,3,40);
                                          }
                                          
                                          if(error != ''){
                                            return error;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                
                                SbInputUnderline(
                                  style: TextStyle(
                                    color: mainColor,
                                  ),
                                  prefixText: '@',
                                  positionText: 'center',
                                  controller: nicknameController,
                                  obscureText: false,
                                  label: 'Nickname',
                                  validatorFunction: (value) {
                                    String error = '';
                                    if(error == ''){
                                      error =  validatorRequired(value!);
                                    }
                            
                                    if(error == ''){
                                      error =  validatorLenght(value!,3,40);
                                    }
                                    
                                    if(error != ''){
                                      return error;
                                    }
                                  },
                                ),
                  
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                
                                        if(user['gender'] == 'M')
                                        Icon(Icons.male,size: 40,color: mainColor,),
                                        if(user['gender'] == 'F')
                                        Icon(Icons.female,size: 40,color: mainColor,),
                
                                        SizedBox(height: 10,),
                                        Divider(height: 1,color: backgroundColorTheme,),
                                        SizedBox(height: 10,),
                
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${user['fairplay']}',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              'fair play',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w300,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(width: 50,),
                                            Text(
                                              '${user['followers_count']}',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              'followers',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w300,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${user['fairplay_collaborator']}',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              'fair play collaboratore',
                                              style: TextStyle(
                                                fontSize: textMid,
                                                fontWeight: FontWeight.w300,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        SizedBox(height: 10,),
                                        Divider(height: 1,color: backgroundColorTheme,),
                                        SizedBox(height: 10,),
                  
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: backgroundColor.withAlpha(50)
                                        ),
                                      )
                                    )
                                  ],
                                ),

                                SbInputUnderline(
                                  controller: bioController, 
                                  obscureText: false,
                                  style: TextStyle(color: textColor),
                                  label: 'Scrivi la tua biografia',
                                  validatorFunction: (value){

                                  }, 
                                  positionText: 'center'
                                ),

                                SizedBox(height: 30,),
                                Text('♫ generi musicali',style: TextStyle(color: textColorSecondary, fontWeight: FontWeight.w400),),
                                SizedBox(height: 10,),
                    
                                Wrap(
                                  runSpacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ...List.generate(
                                      user['music_genres'] != null ? user['music_genres'].length : 0,
                                      (index) {
                                        return GestureDetector(
                                          onTap: (){
                                            user['music_genres'].remove(user['music_genres'][index]);
                                            setState(() {
                                              
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              
                                              Container(
                                                margin: EdgeInsets.all(5),
                                                padding: EdgeInsets.only(top: 2,bottom: 2,right: 10,left: 10),
                                                decoration: BoxDecoration(
                                                  color: mainColor.withAlpha(50),
                                                  borderRadius: BorderRadius.circular(rounded30)
                                                ),
                                                child: Text(
                                                  '♫ ${user['music_genres'][index]['label']}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: textLow,
                                                    fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: mainColor,
                                                    borderRadius: BorderRadius.circular(50)
                                                  ),
                                                  child: Icon(Icons.remove,color: Colors.white, size: 13,),
                                                )
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    ),
                                    if(user['music_genres'] == null || user['music_genres'].length < 5)
                                    GestureDetector(
                                      onTap: (){
                                        if (user['music_genres'] == null) {
                                          user['music_genres'] = [];
                                        }
                                        List musicGenres = user['music_genres'];
                                        
                                        if (_isModalOpen) return; // 👈 evita apertura multipla
                                        _isModalOpen = true;
                                        
                                        Modals().modalMusicGenres(
                                          context,
                                          (gender) {
                                            user['music_genres'].add(gender);
                                            setState(() {});
                                          },
                                          musicGenres,
                                        ).whenComplete(() {
                                          // 👈 Quando la modale si chiude, resettiamo il flag
                                          _isModalOpen = false;
                                        });
                                        
                                        

                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Icon(Icons.add,color: Colors.white, size: 20,),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                    
                          // Foto sopra
                
                          Positioned(
                            top: -70,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog, // clic sulla foto
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: mainColor, // Usa la tua variabile mainColor
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: _image != null
                                  ? Image.file(
                                      _image!,
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      user['picture'] != '' ? "$BASE_URL${user['picture']}${ver()}" : '',
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/images/sballando_no_photo.jpeg",
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    Container(
                      margin: EdgeInsets.only(top: 30, bottom: 30),
                      // padding: EdgeInsets.all(20),
                      width: width(context, 90),
                      decoration: BoxDecoration(
                        // color: backgroundColor,
                        // borderRadius: BorderRadius.circular(40),
                
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   height: 50,
                          //   child: TextFormField(
                          //     controller: birthdateController,
                          //     readOnly: true, // Importantissimo: evita apertura tastiera
                          //     decoration: InputDecoration(
                          //       filled: true,
                          //       fillColor: backgroundColor,
                          //       focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                          //       ),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: grayLight), // bordo normale
                          //       ),
                          //       labelText: 'Data di nascita*',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(8), // Stile simile a SbInput
                          //       ),
                          //     ),
                          //     validator: (value) {
                          //       if (value == null || value.isEmpty) {
                          //         return 'La data è obbligatoria';
                          //       }
                          //       return null;
                          //     },
                          //     onTap: () async {
                
                          //       DateTime today = DateTime.now();
                          //       DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);
                
                          //       DateTime? pickedDate = await showDatePicker(
                          //         context: context,
                          //         initialDate: selectedDate ?? eighteenYearsAgo, // <-- qui cambia
                          //         firstDate: DateTime(1900),
                          //         lastDate: eighteenYearsAgo, // <-- qui resta così
                          //       );
                
                          //       if (pickedDate != null) {
                          //         setState(() {
                          //           selectedDate = pickedDate;
                          //           birthdateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          //         });
                          //       }
                          //     },
                          //   ),
                          // ),
                
                          // SizedBox(height: 20,),
                
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: width(context, 30),
                                  height: 50,
                                  child: DropdownButtonFormField<String>(
                                    value: prefixValue,
                                    dropdownColor: backgroundColor,
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: backgroundColor,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                                        borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: grayLight), // bordo normale
                                        borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                      ),
                                      labelText: 'Prefix',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                      ),
                                    ),
                                    validator: (value) {
                                    },
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        prefixValue = newValue;
                                      });
                                    },
                                    items: prefixList
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                
                              SizedBox(width: 20,),
                
                              SizedBox(
                                width: width(context, 60),
                                height: 50,
                                child: SbInput(
                                  controller: phoneController, 
                                  background: backgroundColor,
                                  obscureText: false, 
                                  label: 'Cellulare', 
                                  validatorFunction: (value){
                                  }
                                ) 
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20,),
                
                          SizedBox(
                            height: 50,
                            child: SbInput(
                              controller: emailController, 
                              background: backgroundColor,
                              obscureText: false, 
                              enabled: false,
                              label: 'Email', 
                              validatorFunction: (value){
                              }
                            ) 
                          ),

                          SizedBox(height: 20,),
                
                          SizedBox(
                            height: 50,
                            child: SbInput(
                              controller: instagramController, 
                              background: backgroundColor,
                              obscureText: false, 
                              enabled: true,
                              label: 'Link Instragram', 
                              validatorFunction: (value){
                              }
                            ) 
                          ),

                          SizedBox(height: 20,),
                
                          SizedBox(
                            height: 50,
                            child: SbInput(
                              controller: tiktokController, 
                              background: backgroundColor,
                              obscureText: false, 
                              enabled: true,
                              label: 'Link TikTok', 
                              validatorFunction: (value){
                              }
                            ) 
                          ),

                          
                          SizedBox(height: 20,),
                
                          SizedBox(
                            height: 50,
                            child: DropdownButtonFormField<String>(
                              style: TextStyle(color: textColor),
                              value: regioneValue,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: backgroundColor,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput

                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: grayLight), // bordo normale
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput

                                ),
                                labelText: 'Regione',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                ),
                              ),
                              dropdownColor: backgroundColor,
                              validator: (value) {
                              },
                              onChanged: (String? newValue) async{
                                regioneValue = newValue;
                                provinciaValue = null;
                                List<String> provinceData = await ApiUser().getProvince(regioneValue!);
                
                                if(provinceData.isNotEmpty){
                                  provinceList = provinceData;
                                }
                                setState(() {
                                  
                                });
                              },
                              items: regioniList
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                
                          SizedBox(height: 20,),
                
                          SizedBox(
                            height: 50,
                            child: DropdownButtonFormField<String>(
                              value: provinciaValue,
                              dropdownColor: backgroundColor,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: backgroundColor,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: mainColor), // bordo quando è attivo
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: grayLight), // bordo normale
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                ),
                                labelText: 'Provincia',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(500), // Stile simile a SbInput
                                ),
                              ),
                              validator: (value) {
                              },
                              onChanged: (String? newValue) {
                                setState(() {
                                  provinciaValue = newValue;
                                });
                              },
                              items: provinceList
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                
                          SizedBox(height: 20,),
                
                          SbButtonMaincolor(
                            fullWidth: true,
                            label: 'Cambia password', 
                            function: (){
                              Modals().modalChangePassword(context);
                            }
                          ),

                          Center(
                            child: SbButtonMaincolor(
                              color: Colors.amber,
                              textColor: Colors.black,
                              
                              fullWidth: true,
                              label: 'Elimina Account',
                              function: () async {
                                Modals().showMessageConfirme(
                                  context, 
                                  'Elimina Account', 
                                  'Sei sicuro di volere eliminare il tuo account?', 
                                  ()async{
                                    Navigator.pop(context);
                                    Modals().loader(context);
                                    dynamic data          = await ApiUser().deleteUser();
                                    if(data != null && data['status'] == true) {
                                      Modals().showMessage(context, 'success', data != null &&  data['message'] != null ? data['message'] : 'Operazione riuscita');
                                      USER = {};
                                      saveShared('json', USER, 'user');
                                      LOGIN = false;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context,'/login');
                                    } else {
                                      Navigator.pop(context);
                                      Modals().showMessage(context, 'error', data != null &&  data['error'] != null ? data['error'] : 'Errore durante l\'operazione');
                                    }
                                  }, 
                                  (){
                                    Navigator.pop(context);
                                  }
                                );
                              }
                            ),
                          ),
                          // SbPolicy(
                          //   policyValue: acceptedPolicy, 
                          //   update: (){
                          //     acceptedPolicy = !acceptedPolicy;
                          //   }, 
                          //   showError: showError,
                          // ),
                
                          // SbSwitch(
                          //   value: vibration,
                          //   label: 'Vibrazione',
                          //   function: (){
                          //     vibration = !vibration;
                          //     saveShared('bool', vibration, 'vibration');
                      
                          //   },
                          // ),
                          // SizedBox(height: 10,),
                          // SbSwitch(
                          //   value: ringtone,
                          //   label: 'Suoneria',
                          //   function: (){
                          //     ringtone = !ringtone;
                          //     saveShared('bool', ringtone, 'ringtone');
                          //   },
                          // ),
                          SizedBox(height: 10,),
                          SbSwitch(
                            value: visibility,
                            label: 'Visibilità',
                            function: (){
                              visibility = !visibility;
                              setState(() {
                    
                              });
                            },
                          ),
                
                          SizedBox(height: 40,),
                          
                          Center(
                            child: SbButtonMaincolor(
                              label: 'Salva',
                              fullWidth: true, 
                              function: () async {
                                
                                // if(acceptedPolicy == false){
                                //   showError = true;
                                //   setState(() {
                                    
                                //   });
                                //   return;
                                // }
                                if(keyForm.currentState!.validate()){
                                  Modals().loader(context);
                                  Map dataUser                  = {};
                                  List genres                   = [];
                                  // prendo solo le id dei generi musicali da passare alla chiamata api
                                  if(user['music_genres'] != null && user['music_genres'].isNotEmpty){
                                    user['music_genres'].forEach((gen){
                                      genres.add(gen['id']);
                                    });
                                  }
                                  

                                  dataUser['name']              = nameController.text != '' ? nameController.text : user['name'];
                                  dataUser['surname']           = surnameController.text != '' ? surnameController.text :  user['surname'];
                                  dataUser['nickname']          = removeAtPrefix(nicknameController.text);
                                  // dataUser['birthday']          = birthdateController.text;
                                  dataUser['phone']             = phoneController.text;
                                  dataUser['prefix_phone']      = prefixValue;
                                  dataUser['link_instagram']    = instagramController.text;
                                  dataUser['link_tiktok']       = tiktokController.text;
                                  dataUser['region']            = regioneValue;
                                  dataUser['gender']            = USER['gender'];

                                  dataUser['visibility']        = bool;
                                  dataUser['visibility']        = visibility;
                                  dataUser['city']              = provinciaValue;
                                  dataUser['bio']               = bioController.text;
                                  dataUser['music_genres']      = genres;
                                  dataUser['picture']           = _image;
                                  
                                  dynamic dataEdit              = await ApiUser().editUser(dataUser);

                                  print(dataEdit);
                                  if(dataEdit == null || dataEdit['status'] == false ) {
                                    Navigator.pop(context);
                                    Modals().showMessage(context, 'error', dataEdit != null &&  dataEdit['error'] != null ? dataEdit['error'] : 'Errore durante l\'operazione');
                                  } else {
                                    Navigator.pop(context);
                                    dynamic dataUserResp            = await ApiUser().getUser(dataUser['nickname']);
                                    if(dataUserResp.isNotEmpty && dataUserResp['status'] != false){
                                      USER = dataUserResp['user'];
                                      saveShared('json', USER, 'user');
                                      Navigator.pushNamed(context,'/profile',);
                                      Modals().showMessage(context, 'success', "Modifiche Salvate");
                                      UP_KEY_IMAGE = Uuid().v4();
                                      setState(() {
                                        
                                      });
                                    }else{
                                      Navigator.pop(context);
                                      Modals().showMessage(context, 'error', "${dataUserResp['error']}");

                                    }
                       
                                  }
                                }
                                
                              }
                            ),
                          ),
                          
                
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ), 
    );
  }
}