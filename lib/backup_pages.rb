#
require 'zip/zip'

module BackupPages
  def self.zip(user)
    zipfile = '%s/wripe.backup.dropbox.%d.zip' % [Dir.tmpdir, user.id]
    FileUtils.rm_rf zipfile if File.exists?(zipfile)
    Zip::ZipFile.open(zipfile, Zip::ZipFile::CREATE) do |zip|
      user.pages.each do |page|
        zip.get_output_stream("page-#{page.id}.txt") do |f|
          f.write [page.title, page.body].join("\n")
        end
      end
    end
    zipfile
  end
end