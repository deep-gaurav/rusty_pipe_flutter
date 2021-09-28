// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart = 2.12

import 'package:artemis/artemis.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'api.graphql.g.dart';

mixin VideoResultFieldsMixin {
  late String videoId;
  late String url;
  late String name;
  late List<VideoResultFieldsMixin$Thumbnail> thumbnail;
  late bool isLive;
  int? duration;
  String? uploaderName;
  String? uploadDate;
  int? viewCount;
}
mixin PlayerStatusFieldsMixin {
  late bool playing;
  int? currentStatus;
  int? totalTime;
}

@JsonSerializable(explicitToJson: true)
class VideoResultFieldsMixin$Thumbnail extends JsonSerializable
    with EquatableMixin {
  VideoResultFieldsMixin$Thumbnail();

  factory VideoResultFieldsMixin$Thumbnail.fromJson(
          Map<String, dynamic> json) =>
      _$VideoResultFieldsMixin$ThumbnailFromJson(json);

  late int width;

  late int height;

  late String url;

  @override
  List<Object?> get props => [width, height, url];
  @override
  Map<String, dynamic> toJson() =>
      _$VideoResultFieldsMixin$ThumbnailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Search$QueryRoot$Search$SearchResult$VideoResult
    extends Search$QueryRoot$Search$SearchResult
    with EquatableMixin, VideoResultFieldsMixin {
  Search$QueryRoot$Search$SearchResult$VideoResult();

  factory Search$QueryRoot$Search$SearchResult$VideoResult.fromJson(
          Map<String, dynamic> json) =>
      _$Search$QueryRoot$Search$SearchResult$VideoResultFromJson(json);

  @override
  List<Object?> get props => [
        videoId,
        url,
        name,
        thumbnail,
        isLive,
        duration,
        uploaderName,
        uploadDate,
        viewCount
      ];
  @override
  Map<String, dynamic> toJson() =>
      _$Search$QueryRoot$Search$SearchResult$VideoResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Search$QueryRoot$Search$SearchResult extends JsonSerializable
    with EquatableMixin {
  Search$QueryRoot$Search$SearchResult();

  factory Search$QueryRoot$Search$SearchResult.fromJson(
      Map<String, dynamic> json) {
    switch (json['__typename'].toString()) {
      case r'VideoResult':
        return Search$QueryRoot$Search$SearchResult$VideoResult.fromJson(json);
      default:
    }
    return _$Search$QueryRoot$Search$SearchResultFromJson(json);
  }

  @JsonKey(name: '__typename')
  String? $$typename;

  @override
  List<Object?> get props => [$$typename];
  @override
  Map<String, dynamic> toJson() {
    switch ($$typename) {
      case r'VideoResult':
        return (this as Search$QueryRoot$Search$SearchResult$VideoResult)
            .toJson();
      default:
    }
    return _$Search$QueryRoot$Search$SearchResultToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class Search$QueryRoot$Search extends JsonSerializable with EquatableMixin {
  Search$QueryRoot$Search();

  factory Search$QueryRoot$Search.fromJson(Map<String, dynamic> json) =>
      _$Search$QueryRoot$SearchFromJson(json);

  late List<Search$QueryRoot$Search$SearchResult> result;

  @override
  List<Object?> get props => [result];
  @override
  Map<String, dynamic> toJson() => _$Search$QueryRoot$SearchToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Search$QueryRoot extends JsonSerializable with EquatableMixin {
  Search$QueryRoot();

  factory Search$QueryRoot.fromJson(Map<String, dynamic> json) =>
      _$Search$QueryRootFromJson(json);

  late Search$QueryRoot$Search search;

  @override
  List<Object?> get props => [search];
  @override
  Map<String, dynamic> toJson() => _$Search$QueryRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus
    extends PlayerMessages$SubscriptionRoot$PlayerMessage
    with EquatableMixin, PlayerStatusFieldsMixin {
  PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus();

  factory PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus.fromJson(
          Map<String, dynamic> json) =>
      _$PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatusFromJson(
          json);

  @override
  List<Object?> get props => [playing, currentStatus, totalTime];
  @override
  Map<String, dynamic> toJson() =>
      _$PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatusToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlayerMessages$SubscriptionRoot$PlayerMessage extends JsonSerializable
    with EquatableMixin {
  PlayerMessages$SubscriptionRoot$PlayerMessage();

  factory PlayerMessages$SubscriptionRoot$PlayerMessage.fromJson(
      Map<String, dynamic> json) {
    switch (json['__typename'].toString()) {
      case r'PlayerStatus':
        return PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus
            .fromJson(json);
      default:
    }
    return _$PlayerMessages$SubscriptionRoot$PlayerMessageFromJson(json);
  }

  @JsonKey(name: '__typename')
  String? $$typename;

  @override
  List<Object?> get props => [$$typename];
  @override
  Map<String, dynamic> toJson() {
    switch ($$typename) {
      case r'PlayerStatus':
        return (this
                as PlayerMessages$SubscriptionRoot$PlayerMessage$PlayerStatus)
            .toJson();
      default:
    }
    return _$PlayerMessages$SubscriptionRoot$PlayerMessageToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerMessages$SubscriptionRoot extends JsonSerializable
    with EquatableMixin {
  PlayerMessages$SubscriptionRoot();

  factory PlayerMessages$SubscriptionRoot.fromJson(Map<String, dynamic> json) =>
      _$PlayerMessages$SubscriptionRootFromJson(json);

  late PlayerMessages$SubscriptionRoot$PlayerMessage playerMessages;

  @override
  List<Object?> get props => [playerMessages];
  @override
  Map<String, dynamic> toJson() =>
      _$PlayerMessages$SubscriptionRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Play$QueryRoot extends JsonSerializable with EquatableMixin {
  Play$QueryRoot();

  factory Play$QueryRoot.fromJson(Map<String, dynamic> json) =>
      _$Play$QueryRootFromJson(json);

  late bool play;

  @override
  List<Object?> get props => [play];
  @override
  Map<String, dynamic> toJson() => _$Play$QueryRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Pause$QueryRoot extends JsonSerializable with EquatableMixin {
  Pause$QueryRoot();

  factory Pause$QueryRoot.fromJson(Map<String, dynamic> json) =>
      _$Pause$QueryRootFromJson(json);

  late bool pause;

  @override
  List<Object?> get props => [pause];
  @override
  Map<String, dynamic> toJson() => _$Pause$QueryRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Resume$QueryRoot extends JsonSerializable with EquatableMixin {
  Resume$QueryRoot();

  factory Resume$QueryRoot.fromJson(Map<String, dynamic> json) =>
      _$Resume$QueryRootFromJson(json);

  late bool resume;

  @override
  List<Object?> get props => [resume];
  @override
  Map<String, dynamic> toJson() => _$Resume$QueryRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Seek$QueryRoot extends JsonSerializable with EquatableMixin {
  Seek$QueryRoot();

  factory Seek$QueryRoot.fromJson(Map<String, dynamic> json) =>
      _$Seek$QueryRootFromJson(json);

  late bool seek;

  @override
  List<Object?> get props => [seek];
  @override
  Map<String, dynamic> toJson() => _$Seek$QueryRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SearchArguments extends JsonSerializable with EquatableMixin {
  SearchArguments({required this.query});

  @override
  factory SearchArguments.fromJson(Map<String, dynamic> json) =>
      _$SearchArgumentsFromJson(json);

  late String query;

  @override
  List<Object?> get props => [query];
  @override
  Map<String, dynamic> toJson() => _$SearchArgumentsToJson(this);
}

final SEARCH_QUERY_DOCUMENT = DocumentNode(definitions: [
  FragmentDefinitionNode(
      name: NameNode(value: 'videoResultFields'),
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
              name: NameNode(value: 'VideoResult'), isNonNull: false)),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'videoId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'url'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'name'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'thumbnail'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                  name: NameNode(value: 'width'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null),
              FieldNode(
                  name: NameNode(value: 'height'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null),
              FieldNode(
                  name: NameNode(value: 'url'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null)
            ])),
        FieldNode(
            name: NameNode(value: 'isLive'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'duration'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'uploaderName'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'uploadDate'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'viewCount'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null)
      ])),
  OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'search'),
      variableDefinitions: [
        VariableDefinitionNode(
            variable: VariableNode(name: NameNode(value: 'query')),
            type:
                NamedTypeNode(name: NameNode(value: 'String'), isNonNull: true),
            defaultValue: DefaultValueNode(value: null),
            directives: [])
      ],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'search'),
            alias: null,
            arguments: [
              ArgumentNode(
                  name: NameNode(value: 'query'),
                  value: VariableNode(name: NameNode(value: 'query')))
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                  name: NameNode(value: 'result'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(selections: [
                    FieldNode(
                        name: NameNode(value: '__typename'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null),
                    InlineFragmentNode(
                        typeCondition: TypeConditionNode(
                            on: NamedTypeNode(
                                name: NameNode(value: 'VideoResult'),
                                isNonNull: false)),
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FragmentSpreadNode(
                              name: NameNode(value: 'videoResultFields'),
                              directives: [])
                        ]))
                  ]))
            ]))
      ]))
]);

class SearchQuery extends GraphQLQuery<Search$QueryRoot, SearchArguments> {
  SearchQuery({required this.variables});

  @override
  final DocumentNode document = SEARCH_QUERY_DOCUMENT;

  @override
  final String operationName = 'search';

  @override
  final SearchArguments variables;

  @override
  List<Object?> get props => [document, operationName, variables];
  @override
  Search$QueryRoot parse(Map<String, dynamic> json) =>
      Search$QueryRoot.fromJson(json);
}

final PLAYER_MESSAGES_SUBSCRIPTION_DOCUMENT = DocumentNode(definitions: [
  FragmentDefinitionNode(
      name: NameNode(value: 'playerStatusFields'),
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
              name: NameNode(value: 'PlayerStatus'), isNonNull: false)),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'playing'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'currentStatus'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null),
        FieldNode(
            name: NameNode(value: 'totalTime'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null)
      ])),
  OperationDefinitionNode(
      type: OperationType.subscription,
      name: NameNode(value: 'playerMessages'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'playerMessages'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null),
              InlineFragmentNode(
                  typeCondition: TypeConditionNode(
                      on: NamedTypeNode(
                          name: NameNode(value: 'PlayerStatus'),
                          isNonNull: false)),
                  directives: [],
                  selectionSet: SelectionSetNode(selections: [
                    FragmentSpreadNode(
                        name: NameNode(value: 'playerStatusFields'),
                        directives: [])
                  ]))
            ]))
      ]))
]);

class PlayerMessagesSubscription
    extends GraphQLQuery<PlayerMessages$SubscriptionRoot, JsonSerializable> {
  PlayerMessagesSubscription();

  @override
  final DocumentNode document = PLAYER_MESSAGES_SUBSCRIPTION_DOCUMENT;

  @override
  final String operationName = 'playerMessages';

  @override
  List<Object?> get props => [document, operationName];
  @override
  PlayerMessages$SubscriptionRoot parse(Map<String, dynamic> json) =>
      PlayerMessages$SubscriptionRoot.fromJson(json);
}

@JsonSerializable(explicitToJson: true)
class PlayArguments extends JsonSerializable with EquatableMixin {
  PlayArguments({required this.videoId});

  @override
  factory PlayArguments.fromJson(Map<String, dynamic> json) =>
      _$PlayArgumentsFromJson(json);

  late String videoId;

  @override
  List<Object?> get props => [videoId];
  @override
  Map<String, dynamic> toJson() => _$PlayArgumentsToJson(this);
}

final PLAY_QUERY_DOCUMENT = DocumentNode(definitions: [
  OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'play'),
      variableDefinitions: [
        VariableDefinitionNode(
            variable: VariableNode(name: NameNode(value: 'videoId')),
            type:
                NamedTypeNode(name: NameNode(value: 'String'), isNonNull: true),
            defaultValue: DefaultValueNode(value: null),
            directives: [])
      ],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'play'),
            alias: null,
            arguments: [
              ArgumentNode(
                  name: NameNode(value: 'videoId'),
                  value: VariableNode(name: NameNode(value: 'videoId')))
            ],
            directives: [],
            selectionSet: null)
      ]))
]);

class PlayQuery extends GraphQLQuery<Play$QueryRoot, PlayArguments> {
  PlayQuery({required this.variables});

  @override
  final DocumentNode document = PLAY_QUERY_DOCUMENT;

  @override
  final String operationName = 'play';

  @override
  final PlayArguments variables;

  @override
  List<Object?> get props => [document, operationName, variables];
  @override
  Play$QueryRoot parse(Map<String, dynamic> json) =>
      Play$QueryRoot.fromJson(json);
}

final PAUSE_QUERY_DOCUMENT = DocumentNode(definitions: [
  OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'pause'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'pause'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null)
      ]))
]);

class PauseQuery extends GraphQLQuery<Pause$QueryRoot, JsonSerializable> {
  PauseQuery();

  @override
  final DocumentNode document = PAUSE_QUERY_DOCUMENT;

  @override
  final String operationName = 'pause';

  @override
  List<Object?> get props => [document, operationName];
  @override
  Pause$QueryRoot parse(Map<String, dynamic> json) =>
      Pause$QueryRoot.fromJson(json);
}

final RESUME_QUERY_DOCUMENT = DocumentNode(definitions: [
  OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'resume'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'resume'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null)
      ]))
]);

class ResumeQuery extends GraphQLQuery<Resume$QueryRoot, JsonSerializable> {
  ResumeQuery();

  @override
  final DocumentNode document = RESUME_QUERY_DOCUMENT;

  @override
  final String operationName = 'resume';

  @override
  List<Object?> get props => [document, operationName];
  @override
  Resume$QueryRoot parse(Map<String, dynamic> json) =>
      Resume$QueryRoot.fromJson(json);
}

@JsonSerializable(explicitToJson: true)
class SeekArguments extends JsonSerializable with EquatableMixin {
  SeekArguments({required this.seconds});

  @override
  factory SeekArguments.fromJson(Map<String, dynamic> json) =>
      _$SeekArgumentsFromJson(json);

  late int seconds;

  @override
  List<Object?> get props => [seconds];
  @override
  Map<String, dynamic> toJson() => _$SeekArgumentsToJson(this);
}

final SEEK_QUERY_DOCUMENT = DocumentNode(definitions: [
  OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'seek'),
      variableDefinitions: [
        VariableDefinitionNode(
            variable: VariableNode(name: NameNode(value: 'seconds')),
            type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
            defaultValue: DefaultValueNode(value: null),
            directives: [])
      ],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
            name: NameNode(value: 'seek'),
            alias: null,
            arguments: [
              ArgumentNode(
                  name: NameNode(value: 'seconds'),
                  value: VariableNode(name: NameNode(value: 'seconds')))
            ],
            directives: [],
            selectionSet: null)
      ]))
]);

class SeekQuery extends GraphQLQuery<Seek$QueryRoot, SeekArguments> {
  SeekQuery({required this.variables});

  @override
  final DocumentNode document = SEEK_QUERY_DOCUMENT;

  @override
  final String operationName = 'seek';

  @override
  final SeekArguments variables;

  @override
  List<Object?> get props => [document, operationName, variables];
  @override
  Seek$QueryRoot parse(Map<String, dynamic> json) =>
      Seek$QueryRoot.fromJson(json);
}
