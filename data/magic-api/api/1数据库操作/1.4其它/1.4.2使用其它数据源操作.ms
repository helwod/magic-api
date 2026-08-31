{
  "properties" : { },
  "id" : "d20f236bbdcb4313bf36dcf15a870173",
  "script" : null,
  "groupId" : "b84bbe97a3d54de69e5a305d75048c4f",
  "name" : "1.4.2使用其它数据源操作",
  "createTime" : 1787823279309,
  "updateTime" : 1787901163748,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/switch",
  "method" : "POST",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": [\n        {\n            \"1\": 1\n        }\n    ],\n    \"timestamp\": 1787901159901,\n    \"executeTime\": 10\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
// 使用key为slave的数据源进行查询，其它操作同理
return db.mysql.select("select 1")