{
  "properties" : { },
  "id" : "06be109b0fdc4df298aaba971b6a2016",
  "script" : null,
  "groupId" : "b84bbe97a3d54de69e5a305d75048c4f",
  "name" : "1.4.4使用缓存",
  "createTime" : 1787823279315,
  "updateTime" : 1787902901903,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/cache",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": -1,\n    \"message\": \"系统内部出现错误\",\n    \"data\": null,\n    \"timestamp\": 1787902785521,\n    \"executeTime\": 10\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
// 清空名为user的缓存
// db.deleteCache('user')

// 当执行 update/insert/等修改语句时，会自动清空名为user的缓存
// db.cache('user').update('......')
return db.magic.cache('user',2000)  // 使用缓存名为user的缓存,有效期为2s
    .select('select * from user');
    
// db.cache('user',2000).table('sys_user').select()


// 自定义缓存实现：https://www.ssssssss.org/magic-api/pages/senior/cache/