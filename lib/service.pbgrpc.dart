//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'service.pb.dart' as $0;

export 'service.pb.dart';

//@$pb.GrpcServiceName('PredictionService')
class PredictionServiceClient extends $grpc.Client {
  static final _$sendImage = $grpc.ClientMethod<$0.ImageRequest, $0.ImageResponse>(
      '/PredictionService/SendImage',
      ($0.ImageRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ImageResponse.fromBuffer(value));

  PredictionServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ImageResponse> sendImage($0.ImageRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendImage, request, options: options);
  }
}

//@$pb.GrpcServiceName('PredictionService')
abstract class PredictionServiceBase extends $grpc.Service {
  $core.String get $name => 'PredictionService';

  PredictionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ImageRequest, $0.ImageResponse>(
        'SendImage',
        sendImage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ImageRequest.fromBuffer(value),
        ($0.ImageResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ImageResponse> sendImage_Pre($grpc.ServiceCall call, $async.Future<$0.ImageRequest> request) async {
    return sendImage(call, await request);
  }

  $async.Future<$0.ImageResponse> sendImage($grpc.ServiceCall call, $0.ImageRequest request);
}
