fs          = require 'fs'
_existsSync = fs.existsSync || path.existsSync
imagemagick = require 'imagemagick'
path        = require 'path'
async       = require 'async'

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
    rootPath = path.dirname(file.path) + '/' + user._id + '/picture'
    async.series
      validate: (callback) ->
        self.validate file, callback
      createUserDirIfNotExists: (callback) ->
        fs.exists rootPath, (exists) ->
          if exists then self.createUserDir user, rootPath, callback else callback
      saveUserPictureVersions: (callback) ->
        self.saveUserPictureVersions user, file callback
      unlink: (callback) ->
        fs.unlink file.path, callback
    , callback

  @createUserDir = (user, rootPath, callback) ->
    fs.mkdir rootPath, (err) ->
      return callback(err) if err
      mkVersionDir = (version) ->
        fs.mkdir rootPath + '/' + user._id + '/picture/' + version
      async.eachSeries Object.keys(config.imageVersions), mkVersionDir, callback

  @saveUserPictureVersions = (user, file, callback) ->
    Object.keys(config.imageVersions).forEach (version) ->
        opts = config.imageVersions[version]
        user.picture[version] = path.basename(file.path)
        imagemagick.resize
          width: opts.width
          height: opts.height
          srcPath: file.path
          dstPath: path.dirname(file.path) + '/' + user._id + '/picture/' + version + '/' + path.basename(file.path)
        , callback

  @initUrls = (host) ->
    self = this
    baseUrl = ((if config.sslEnabled then "https:" else "http:")) + "//" + host + config.uploadUrl
    selfurl = selfdeleteUrl = baseUrl + encodeURIComponent(file.name)
    Object.keys(config.imageVersions).forEach (version) ->
      self[version + "Url"] = baseUrl + version + "/" + encodeURIComponent(self.name)  if _existsSync(config.uploadDir + "/" + version + "/" + self.name)

  return

module.exports = Image
