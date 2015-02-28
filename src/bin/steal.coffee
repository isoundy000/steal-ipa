config = require '../config'
fs = require 'fs'
parseXml = require('xml2js').parseString
argv = require 'yargs'
  .option 's',
    alias: 'short'
    describe: '应用的短地址, 如 yAwk'
    required: true
  .option 'o',
    alias: 'output'
    describe: '输出文件名, 如 yAwk.ipa'
  .argv
request = require 'request'
request.get config.pgyerUrl(argv.s), (err, res, body) ->
  throw err if err?

  installUrl = /\/app\/install\/\w{32,32}/gi.exec body
  throw '短地址有误' if !installUrl?
  request.get url:config.pgyerUrl(installUrl[0]), followRedirect:false, (err, res, body) ->
    throw err if err?
    plistUrl = /url=(.*\.plist)/.exec res.headers.location
    request.get url:plistUrl[1], headers: 'User-Agent': 'iTunes/9.1.1', (err, res, body) ->
      throw err if err?
      output = argv.o || "#{argv.s}.ipa"
      ipaUrl = /http[^<]+?auth_key[^<]+/.exec body
      console.log '正在下载'
      request.get(ipaUrl[0]).pipe fs.createWriteStream output

