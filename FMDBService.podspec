Pod::Spec.new do |s|
s.name         = "FMDBService"
s.version      = "0.2.03"
s.summary      = "An SQLite Framework,based FMDB, automatic database operation thread-safe and no recursive deadlock"
s.description  = "support:NSArray,NSDictionary, ModelClass, NSNumber, NSString, NSDate, NSData, UIColor, UIImage, CGRect, CGPoint, CGSize, NSRange, int,char,float, double, long.."
s.homepage     = "https://github.com/ideaPods/FMDBService"
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { "WilliamQiu" => "ideapods@163.com" }
s.platform     = :ios, '7.0'
s.frameworks   = 'Foundation'
s.source       = { :git => "https://github.com/ideaPods/FMDBService.git"}
s.source_files  = 'FMDBService', 'FMDBService/**/*.{h,m}'
s.vendored_frameworks = ''
s.resources    = ''

s.requires_arc = true
s.dependency "FMDB" , "~> 2.6.2"
end
