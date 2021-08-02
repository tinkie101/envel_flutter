import 'package:oauth2/oauth2.dart' as oauth2;

class Auth {
  final authorizationEndpoint = Uri.parse('http://localhost:9090/auth/realms/envel/protocol/openid-connect/token');

// The user should supply their own username and password.
  final username = 'avolschenk';
  final password = 'password';

// The authorization server may issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Some servers don't require the client to authenticate itself, in which case
// these should be omitted.
  final identifier = 'spring-client';
  final secret = '0541ad92-d430-4a3a-ae86-4184ea907490';

// Make a request to the authorization endpoint that will produce the fully
// authenticated Client.
  getClient() async {
    return await oauth2.resourceOwnerPasswordGrant(authorizationEndpoint, username, password,
        identifier: identifier, secret: secret);
  }
}
