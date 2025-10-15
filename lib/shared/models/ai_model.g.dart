// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiChatRequestImpl _$$AiChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$AiChatRequestImpl(
      message: json['message'] as String,
    );

Map<String, dynamic> _$$AiChatRequestImplToJson(_$AiChatRequestImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

_$AiFeedbackRequestImpl _$$AiFeedbackRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AiFeedbackRequestImpl(
      itemName: json['itemName'] as String?,
      entpName: json['entpName'] as String?,
      question: json['question'] as String?,
      context: json['context'] as String?,
    );

Map<String, dynamic> _$$AiFeedbackRequestImplToJson(
        _$AiFeedbackRequestImpl instance) =>
    <String, dynamic>{
      'itemName': instance.itemName,
      'entpName': instance.entpName,
      'question': instance.question,
      'context': instance.context,
    };

_$AiResponseImpl _$$AiResponseImplFromJson(Map<String, dynamic> json) =>
    _$AiResponseImpl(
      reply: json['reply'] as String?,
      answer: json['answer'] as String?,
      answerType: json['answerType'] as String?,
      productName: json['productName'] as String?,
      source: json['source'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AiResponseImplToJson(_$AiResponseImpl instance) =>
    <String, dynamic>{
      'reply': instance.reply,
      'answer': instance.answer,
      'answerType': instance.answerType,
      'productName': instance.productName,
      'source': instance.source,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$AiFeedbackLogImpl _$$AiFeedbackLogImplFromJson(Map<String, dynamic> json) =>
    _$AiFeedbackLogImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      kind: json['kind'] as String,
      requestText: json['requestText'] as String,
      responseText: json['responseText'] as String?,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AiFeedbackLogImplToJson(_$AiFeedbackLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'kind': instance.kind,
      'requestText': instance.requestText,
      'responseText': instance.responseText,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
    };
