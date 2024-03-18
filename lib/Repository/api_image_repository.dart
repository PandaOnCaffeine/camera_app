import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:universal_io/io.dart';
import 'package:localstorage/localstorage.dart';

// My Image Repository
import 'image_repository.dart';

class ApiImageRepository implements ImageRepository {
  final String _apiUri = "https://10.0.2.2:7044";
  final storage = LocalStorage('my_jwt_data.json');

  @override
  Future<void> saveImage(String imageBase64) async {
    try {
      // Get Jwt Token
      storage.ready;
      final String jwt = storage.getItem('jwt_key');
      if(jwt.isEmpty){
        print("No JWT TOKEN");
        return;
      }


      // BaseUrl With Endpoint
      String uriString = "$_apiUri/Camera/PostImage";
      var uri = Uri.parse(uriString);
      print('API uri: $uri');

      // Encode the request body
      Map<String, String> requestBody = {
        'imageBase64': imageBase64,
      };

      // JsonEncode RequestBody
      String requestBodyJson = jsonEncode(requestBody);

      // Create HttpClient
      // HttpClient httpClient = HttpClient();
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                true; // Only for Testing. Not recomended for production

      var request = await httpClient.postUrl(uri);

      // Set headers
      request.headers.contentType = ContentType.json;
      request.headers.add('accept', '*/*');
      request.headers.add('Authorization', 'Bearer $jwt');

      // Write the request body
      request.write(requestBodyJson);
      print('API requestBodyJson: $requestBodyJson');

      // Close the request and get the response
      HttpClientResponse response = await request.close();

      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        // If the server returns a 200 OK response, parse the JSON
        String responseBody = await response.transform(utf8.decoder).join();

        ///
        /// Compute
        final parsedResponse = await compute(jsonDecode,responseBody);
        ///
        print('Response: $parsedResponse');
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to save image: ${response.statusCode}');
      }

      // Close the HttpClient
      httpClient.close();
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      throw Exception('Failed to save image: $e');
    }
  }

  @override
  Future<List<String>> getImages() async {
    try {
      // Get Jwt Token
      storage.ready;
      final String jwt = storage.getItem('jwt_key');

      // BaseUrl With Endpoint
      String uriString = "$_apiUri/Camera/GetImages";
      print('API uriString: $uriString');

      var uri = Uri.parse(uriString);
      print('API uri: $uri');

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                true; // Only for Testing. Not recomended for production

      var request = await httpClient.getUrl(uri);

      // Set headers
      request.headers.add('accept', 'text/plain');
      request.headers.add('Authorization', 'Bearer $jwt');

      // Close the request and get the response
      HttpClientResponse response = await request.close();
      print("Api response: $response");
      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        // If the server returns a 200 OK response, parse the JSON
        String responseBody = await response.transform(utf8.decoder).join();
        List<dynamic> jsonList = jsonDecode(responseBody);

        print("Api jsonList: $jsonList");
        List<String> imageBase64List = jsonList
            .map((image) => image['imageBase64'])
            .cast<String>()
            .toList();

        print(
            "Api imageBase64 1: length: ${imageBase64List[0].length} : ${imageBase64List[0]}");
        return imageBase64List;
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to get images: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      throw Exception('Failed to get images: $e');
    }
  }

  Future<void> login() async {
    try {
      // BaseUrl With Endpoint
      String uriString = "$_apiUri/Camera/Login";
      var uri = Uri.parse(uriString);

      // Encode the request body
      Map<String, String> requestBody = {
        'Username': "TestUser",
        'Password': "TestPassword"
      };
      // JsonEncode RequestBody
      String requestBodyJson = jsonEncode(requestBody);

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                true; // Only for Testing. Not recomended for production

      var request = await httpClient.postUrl(uri);

      // Set headers
      request.headers.contentType = ContentType.json;
      request.headers.add('accept', '*/*');

      // Write the request body
      request.write(requestBodyJson);

      // Close the request and get the response
      HttpClientResponse response = await request.close();
      print("Api response: $response");
      // Check the response status code
      if (response.statusCode == HttpStatus.ok) {
        // If the server returns a 200 OK response

        storage.ready;
        storage.setItem('jwt_key', response);
        // storage.setItem('refresh_key', value)
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
    }
  }
}