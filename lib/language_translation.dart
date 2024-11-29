import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class LanguageTranslator extends StatefulWidget {
  const LanguageTranslator({super.key});

  @override
  State<StatefulWidget> createState() => _LanguageStatePage();
}

class _LanguageStatePage extends State<LanguageTranslator> {
  final List<String> languages = [
    'Arabic', 'Bengali', 'Dutch', 'English', 'French',
    'German', 'Greek', 'Hindi', 'Italian', 'Japanese', 'Korean', 'Persian',
    'Polish', 'Portuguese', 'Russian', 'Spanish', 'Turkish', 'Urdu', 'Vietnamese'
  ];

  String originalLanguage = 'From';
  String destinationLanguage = 'To';
  String output = '';
  final TextEditingController languageController = TextEditingController();
  bool isOnline = true;

  void translate(String src, String dest, String input) async {
    if (input.isEmpty) {
      setState(() {
        output = 'Write text to translate';
      });
      return;
    } else if (src == "--" || dest == "--") {
      setState(() {
        output = 'Select the language';
      });
      return;
    }

    // Show loading toast
    Fluttertoast.showToast(
      msg: "Translating...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue.shade900,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Perform translation
    GoogleTranslator translator = GoogleTranslator();
    var translation = await translator.translate(input, from: src, to: dest);

    // Hide the toast after translation is done
    Fluttertoast.cancel();

    setState(() {
      output = translation.text;
    });
  }

  String getLanguageCode(String language) {
    switch (language) {
      case 'Arabic': return 'ar';
      case 'Bengali': return 'bn';
      case 'Dutch': return 'nl';
      case 'English': return 'en';
      case 'French': return 'fr';
      case 'German': return 'de';
      case 'Greek': return 'el';
      case 'Hindi': return 'hi';
      case 'Italian': return 'it';
      case 'Japanese': return 'ja';
      case 'Korean': return 'ko';
      case 'Persian': return 'fa';
      case 'Polish': return 'pl';
      case 'Portuguese': return 'pt';
      case 'Russian': return 'ru';
      case 'Spanish': return 'es';
      case 'Turkish': return 'tr';
      case 'Urdu': return 'ur';
      case 'Vietnamese': return 'vi';
      default: return '--';
    }
  }

  Future<void> checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool online = connectivityResult != ConnectivityResult.none;
    setState(() {
      isOnline = online;
    });
  }

  Future<bool> isNetworkConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No connectivity at all
      Fluttertoast.showToast(
        msg: "No internet connection. Please turn on your network.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    } else {
      // Check if we can actually reach the internet (via simple ping)
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true; // Internet is available
        }
      } catch (e) {
        // No actual internet despite being connected to a network
        Fluttertoast.showToast(
          msg: "No internet connection. Please check your network.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }
    return false;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    checkNetworkStatus(); // Check status on startup

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Handle the list of connectivity results
      bool online = results.isNotEmpty && results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
      setState(() {
        isOnline = online;
      });
      if (!online) {
        Fluttertoast.showToast(
          msg: "You are offline. Please check your internet connection.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Language Translator",
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child:Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8), // Add some space between the icon and text
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: isOnline ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )

          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DropdownButton(
                          focusColor: Colors.blue.shade800,
                          iconDisabledColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          hint: Text(
                            originalLanguage,
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          dropdownColor: Colors.blue.shade600,
                          icon: const Icon(Icons.language, color: Colors.white),
                          items: languages.map((String dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              originalLanguage = value!;
                            });
                          },
                        ),
                        const Icon(Icons.arrow_right_alt,
                            size: 40, color: Colors.white),
                        DropdownButton(
                          focusColor: Colors.blue.shade800,
                          iconDisabledColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          hint: Text(
                            destinationLanguage,
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          dropdownColor: Colors.blue.shade600,
                          icon: const Icon(Icons.language, color: Colors.white),
                          items: languages.map((String dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              destinationLanguage = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      autofocus: false,
                      cursorColor: Colors.white,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue.shade600,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Enter text',
                        labelStyle: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      controller: languageController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a text to translate";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          bool connected = await isNetworkConnected();
                          print("Network connected: $connected"); // Debug print

                          if (connected) {
                            translate(
                              getLanguageCode(originalLanguage),
                              getLanguageCode(destinationLanguage),
                              languageController.text,
                            );
                          }
                        },

                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade900, Colors.blue.shade800],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                        child: Text(
                          "Translate",
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      output,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Powered by ",
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchUrl("https://codecamp.website");
                      },
                      child: Text(
                        "codecamp.website",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 18,
        child: FloatingActionButton(
          onPressed: () => exit(0),
          backgroundColor: Colors.red,
          child: const Icon(Icons.exit_to_app, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
