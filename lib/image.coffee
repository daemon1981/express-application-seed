fs          = require 'fs'
_existsSync = fs.existsSync || path.existsSync
imagemagick = require 'imagemagick'
path        = require 'path'
async       = require 'async'
exec        = require('child_process').exec

Image = (config) ->
  self = this

  @validate = (file, callback) ->
    if config.minFileSize and config.minFileSize > file.size
      return callback new Error('File is too small')
    else if config.maxFileSize and config.maxFileSize < file.size
      return callback new Error('File is too big')
    else return callback new Error('Filetype not allowed') unless /\.(gif|jpe?g|png)$/i.test(file.name)

    callback null

  @saveUserPicture = (user, file, callback) ->
    rootPath = path.dirname(file.path)
    async.series
      validate: (callback) ->
        self.validate file, callback
      createUserDir: (callback) ->
        self.createUserDir user, rootPath, callback
      saveUserPictureVersions: (callback) ->
        self.saveUserPictureVersions user, rootPath, file.path, callback
      unlink: (callback) ->
        fs.unlink file.path, callback
    , callback

  @createUserDir = (user, rootPath, callback) ->
    mkVersionDir = (version, next) ->
      exec 'mkdir -p ' + self.getVersionPath(user, version, rootPath), next
    async.eachSeries Object.keys(config.imageVersions), mkVersionDir, callback

  @getVersionPath = (user, version, rootPath) ->
    rootPath + '/' + user._id + '/picture' + '/' + version

  @saveUserPictureVersions = (user, rootPath, filePath, callback) ->
    Object.keys(config.imageVersions).forEach (version) ->
      opts = config.imageVersions[version]
      user.picture[version] = path.basename(filePath)
      imagemagick.resize
        width: opts.width
        height: opts.height
        srcPath: filePath
        dstPath: self.getVersionPath(user, version, rootPath) + '/' + path.basename(filePath)
      , callback

  @initUrls = (host) ->
    self = this
    baseUrl = ((if config.sslEnabled then "https:" else "http:")) + "//" + host + config.uploadUrl
    selfurl = selfdeleteUrl = baseUrl + encodeURIComponent(file.name)
    Object.keys(config.imageVersions).forEach (version) ->
      self[version + "Url"] = baseUrl + version + "/" + encodeURIComponent(self.name)  if _existsSync(config.uploadDir + "/" + version + "/" + self.name)

  return

module.exports = Image
