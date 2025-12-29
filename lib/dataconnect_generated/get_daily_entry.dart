part of 'generated.dart';

class GetDailyEntryVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetDailyEntryVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetDailyEntryData> dataDeserializer = (dynamic json)  => GetDailyEntryData.fromJson(jsonDecode(json));
  Serializer<GetDailyEntryVariables> varsSerializer = (GetDailyEntryVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetDailyEntryData, GetDailyEntryVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetDailyEntryData, GetDailyEntryVariables> ref() {
    GetDailyEntryVariables vars= GetDailyEntryVariables(id: id,);
    return _dataConnect.query("GetDailyEntry", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetDailyEntryDailyEntry {
  final String id;
  final String userId;
  final Timestamp createdAt;
  final DateTime entryDate;
  final String? mood;
  final String? notes;
  GetDailyEntryDailyEntry.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  userId = nativeFromJson<String>(json['userId']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  entryDate = nativeFromJson<DateTime>(json['entryDate']),
  mood = json['mood'] == null ? null : nativeFromJson<String>(json['mood']),
  notes = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetDailyEntryDailyEntry otherTyped = other as GetDailyEntryDailyEntry;
    return id == otherTyped.id && 
    userId == otherTyped.userId && 
    createdAt == otherTyped.createdAt && 
    entryDate == otherTyped.entryDate && 
    mood == otherTyped.mood && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, userId.hashCode, createdAt.hashCode, entryDate.hashCode, mood.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['userId'] = nativeToJson<String>(userId);
    json['createdAt'] = createdAt.toJson();
    json['entryDate'] = nativeToJson<DateTime>(entryDate);
    if (mood != null) {
      json['mood'] = nativeToJson<String?>(mood);
    }
    if (notes != null) {
      json['notes'] = nativeToJson<String?>(notes);
    }
    return json;
  }

  GetDailyEntryDailyEntry({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.entryDate,
    this.mood,
    this.notes,
  });
}

@immutable
class GetDailyEntryData {
  final GetDailyEntryDailyEntry? dailyEntry;
  GetDailyEntryData.fromJson(dynamic json):
  
  dailyEntry = json['dailyEntry'] == null ? null : GetDailyEntryDailyEntry.fromJson(json['dailyEntry']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetDailyEntryData otherTyped = other as GetDailyEntryData;
    return dailyEntry == otherTyped.dailyEntry;
    
  }
  @override
  int get hashCode => dailyEntry.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (dailyEntry != null) {
      json['dailyEntry'] = dailyEntry!.toJson();
    }
    return json;
  }

  GetDailyEntryData({
    this.dailyEntry,
  });
}

@immutable
class GetDailyEntryVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetDailyEntryVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetDailyEntryVariables otherTyped = other as GetDailyEntryVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetDailyEntryVariables({
    required this.id,
  });
}

