import 'package:grpc/grpc.dart';
import 'service.pb.dart';
import 'service.pbgrpc.dart';

class GrpcClient {
  late final ClientChannel channel;
  late final PredictionServiceClient stub;

  GrpcClient() {
    // Configure the channel and stub
    channel = ClientChannel(
      '127.0.0.1', // Use your server's IP if running on a physical device
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    stub = PredictionServiceClient(channel);
  }

  // Correctly return the response from gRPC
  Future<ImageResponse> sendImage(ImageRequest request) async {
    try {
      final response = await stub.sendImage(request);
      return response; // Return response to be used in main.dart
    } catch (e) {
      print('Caught gRPC error: $e');
      rethrow; // Ensure that the error can be caught in main.dart
    }
  }

  void shutdown() async {
    await channel.shutdown();
  }
}
