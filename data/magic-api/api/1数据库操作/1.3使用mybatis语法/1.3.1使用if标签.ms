{
  "properties" : { },
  "id" : "8552b623032c40609cbe422976a7bc91",
  "script" : null,
  "groupId" : "8505cc65c46145bdb3e20a0ff5d14699",
  "name" : "1.3.1使用if标签",
  "createTime" : 1787823279287,
  "updateTime" : 1787900942076,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/if",
  "method" : "POST",
  "parameters" : [ {
    "name" : "name",
    "value" : "测试",
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
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": [\n        {\n            \"User\": \"magic\"\n        },\n        {\n            \"User\": \"root\"\n        },\n        {\n            \"User\": \"mysql.infoschema\"\n        },\n        {\n            \"User\": \"mysql.session\"\n        },\n        {\n            \"User\": \"mysql.sys\"\n        }\n    ],\n    \"timestamp\": 1787900935768,\n    \"executeTime\": 15\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : {
    "name" : "",
    "value" : "",
    "description" : "",
    "required" : false,
    "dataType" : "Object",
    "type" : null,
    "defaultValue" : null,
    "validateType" : "",
    "error" : "",
    "expression" : "",
    "children" : [ {
      "name" : "code",
      "value" : "1",
      "description" : "",
      "required" : false,
      "dataType" : "Integer",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "message",
      "value" : "success",
      "description" : "",
      "required" : false,
      "dataType" : "String",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "data",
      "value" : "",
      "description" : "",
      "required" : false,
      "dataType" : "Array",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ {
        "name" : "",
        "value" : "",
        "description" : "",
        "required" : false,
        "dataType" : "Object",
        "type" : null,
        "defaultValue" : null,
        "validateType" : "",
        "error" : "",
        "expression" : "",
        "children" : [ {
          "name" : "api_name",
          "value" : "测试",
          "description" : "",
          "required" : false,
          "dataType" : "String",
          "type" : null,
          "defaultValue" : null,
          "validateType" : "",
          "error" : "",
          "expression" : "",
          "children" : [ ]
        } ]
      } ]
    }, {
      "name" : "timestamp",
      "value" : "1679881229013",
      "description" : "",
      "required" : false,
      "dataType" : "Long",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "executeTime",
      "value" : "9",
      "description" : "",
      "required" : false,
      "dataType" : "Integer",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    } ]
  }
}
================================
// 文档： https://www.ssssssss.org/magic-api/pages/quick/crud/#mybatis%E8%AF%AD%E6%B3%95%E6%94%AF%E6%8C%81

//var User = "root" // 设置User 只条件存在
return db.mysql.select("""
    select distinct User from user

    <where>
        <if test="User != null and User != '' ">
         and User like concat('%',#{User},'%')
        </if>
    </where>
""")