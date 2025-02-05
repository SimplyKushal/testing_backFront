import grpc
from concurrent import futures
import service_pb2, service_pb2_grpc
import cv2
import numpy as np
import os

# Create a directory to save received images
SAVE_DIR = 'received_images'
os.makedirs(SAVE_DIR, exist_ok=True)

class ImageProcessingService(service_pb2_grpc.ImageProcessingServiceServicer):  # Correct the class name
    def SendImage(self, request, context):  # Update method name to SendImage
        try:
            # Convert bytes to NumPy array
            np_image = np.frombuffer(request.imageData, dtype=np.uint8)  # Use imageData as defined in .proto
            frame = cv2.imdecode(np_image, cv2.IMREAD_COLOR)

            if frame is not None:
                # Save the received image to the local folder
                file_path = os.path.join(SAVE_DIR, 'received_image.png')
                cv2.imwrite(file_path, frame)
                print(f"Image successfully saved to {file_path}")

                # Display the image (optional)
                cv2.imshow("Received Frame", frame)
                cv2.waitKey(1)  # Show for a short period

                return service_pb2.ImageResponse(message='Frame processed and saved successfully')
            else:
                return service_pb2.ImageResponse(message='Failed to decode image')

        except Exception as e:
            print(f"Error processing frame: {e}")
            return service_pb2.ImageResponse(message=f"Error: {str(e)}")

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    service_pb2_grpc.add_ImageProcessingServiceServicer_to_server(ImageProcessingService(), server)
    server.add_insecure_port('[::]:50051')
    print("Starting gRPC server on port 50051...")
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
