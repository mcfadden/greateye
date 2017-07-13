class Camera::Amcrest < Camera
  include Concerns::CameraInteractionMethod::Ftp
  include Concerns::CameraEventVideoProcessing::FfmpegH264Source
  include Concerns::CameraEventVideoProcessing::SingleVideoFile
end
