{
  "properties" : { },
  "id" : "519573c20541450e8721d529df0a4ea0",
  "script" : null,
  "groupId" : "8350c5f638d9400fa9c44f46412bba31",
  "name" : "1.1.4删除数据",
  "createTime" : 1787823279249,
  "updateTime" : 1787887475865,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/delete",
  "method" : "DELETE",
  "parameters" : [ {
    "name" : "id",
    "value" : "123",
    "description" : null,
    "required" : false,
    "dataType" : "String",
    "type" : null,
    "defaultValue" : null,
    "validateType" : null,
    "error" : null,
    "expression" : null,
    "children" : null
  } ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": -1,\n    \"message\": \"系统内部出现错误\",\n    \"data\": null,\n    \"timestamp\": 1787887473500,\n    \"executeTime\": 18\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
// 相关API：https://www.ssssssss.org/magic-api/pages/module/db/#%E5%8D%95%E8%A1%A8%E6%93%8D%E4%BD%9Capi
return mysql.table('users')
        .where()
        .eq('id', id)
        .delete();