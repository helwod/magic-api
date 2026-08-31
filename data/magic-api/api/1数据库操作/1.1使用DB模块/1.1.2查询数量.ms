{
  "properties" : { },
  "id" : "eec97339674b45eab3a56035592ca317",
  "script" : null,
  "groupId" : "8350c5f638d9400fa9c44f46412bba31",
  "name" : "1.1.2查询数量",
  "createTime" : 1787823279236,
  "updateTime" : 1787888409185,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/count",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": 6,\n    \"timestamp\": 1787888374162,\n    \"executeTime\": 36\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
// 相关API：https://www.ssssssss.org/magic-api/pages/module/db/#%E5%8D%95%E8%A1%A8%E6%93%8D%E4%BD%9Capi
return db.mysql.table('user').count()
