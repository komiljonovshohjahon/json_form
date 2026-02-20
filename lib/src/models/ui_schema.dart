class UiSchemaData {
  final Map<String, Object?> _asJson = {};
  String? title;
  String? description;
  UiSchemaData? globalOptions;
  UiSchemaData? parent;
  final Map<String, UiSchemaData> children = {};

  ///
  /// General Options
  ///
  String? help;
  bool readOnly = false;
  bool disabled = false;
  bool hidden = false;
  bool hideError = false;
  double? width;

  ///
  /// String Options
  ///
  String? placeholder;
  String? emptyValue;
  bool autofocus = false;
  bool autocomplete = false;

  ///
  /// Date Options
  ///
  List<int>? yearsRange; // TODO: negative values

  /// Date format MDY, DMY and YMD (default)
  String format = 'YMD';
  bool hideNowButton = false;
  bool hideClearButton = false;

  /// boolean: radio, select, checkbox (default)
  /// string: textarea, password, color, file
  /// number: updown, range, radio
  /// array: checkboxes
  String? widget;

  /// With "widget=file" or "format=data-url": accept='.pdf'
  String? accept;

  /// Displayed as text if is not empty
  List<String>? enumNames;
  List<String>? enumDisabled;
  List<String>? order;

  ///
  /// Array Options
  ///
  bool inline = false;
  bool addable = true;
  bool removable = true;
  bool orderable = true;
  bool copyable = true;

  Map<String, Object?> toJson() => {
    'ui:options': _asJson,
    for (final e in children.entries) e.key: e.value.toJson(),
  };

  void setGlobalOptions(
    Map<String, Object?> data, {
    required bool fromOptions,
  }) {
    globalOptions ??= UiSchemaData();
    globalOptions!.setUi(data, parent: this, fromOptions: fromOptions);
    setUi(data, parent: null, fromOptions: fromOptions, fromGlobal: true);
  }

  void setUi(
    Map<String, dynamic> uiSchema, {
    required UiSchemaData? parent,
    bool fromOptions = false,
    bool fromGlobal = false,
  }) {
    this.parent = parent ?? this.parent;
    if (parent != null &&
        parent.globalOptions != null &&
        this != parent.globalOptions) {
      setGlobalOptions(parent.globalOptions!.toJson(), fromOptions: false);
    }
    // if (fromOptions) {
    //   final options = asJson['ui:options'] as Map<String, Object?>? ?? {};
    //   asJson['ui:options'] = options;
    //   options.addAll(uiSchema);
    // } else {
    //   asJson.addAll(uiSchema);
    // }
    uiSchema.forEach((key, data) {
      final split = key.split(':');
      final String k;
      if (fromOptions) {
        k = key;
      } else if (split.length == 2 && split.first == 'ui') {
        k = split.last;
        // } else if (data is Map<String, dynamic>) {
        //   final nested = nestedProperties[key] ?? UiSchemaData();
        //   nestedProperties[key] = nested;
        //   nested.setUi(data, fromOptions: false, parent: this);
        //   return;
      } else {
        return;
      }
      if (fromGlobal && _asJson.containsKey(k)) return;
      bool saveInJson = !fromGlobal;
      switch (k) {
        case 'disabled':
          disabled = data as bool;
        // TODO: filePreview, label=false, type:password
        // rows/width
        case 'autofocus':
          autofocus = data as bool;
        case 'autocomplete':
          autocomplete = data as bool;
        case 'hideError':
          hideError = data as bool;
        case 'width':
          width = (data as num).toDouble();
        case 'enumDisabled':
          enumDisabled = (data as List).cast();
        case 'enumNames':
          enumNames = (data as List).cast();
        case 'emptyValue':
          emptyValue = data as String;
        case 'title':
          title = data as String;
        case 'description':
          description = data as String;
        case 'help':
          help = data as String;
        case 'placeholder':
          placeholder = data as String;
        case 'readonly':
          readOnly = data as bool;
        case 'hidden':
          hidden = data as bool;
        case 'widget':
          // TODO: password, textarea, inputType:tel,email?
          widget = data as String;
        case 'yearsRange':
          yearsRange = data as List<int>;
        case 'format':
          format = data as String;
        case 'hideNowButton':
          hideNowButton = data as bool;
        case 'hideClearButton':
          hideClearButton = data as bool;
        case 'order':
          order = (data as List).cast();

        ///
        /// Array Properties
        ///
        case 'addable':
          addable = data as bool;
        case 'removable':
          removable = data as bool;
        case 'orderable':
          orderable = data as bool;
        case 'copyable':
          copyable = data as bool;
        case 'options':
          setUi(
            data as Map<String, Object?>,
            fromOptions: true,
            parent: null,
            fromGlobal: fromGlobal,
          );
          saveInJson = false;
        case 'globalOptions':
          setGlobalOptions(data as Map<String, Object?>, fromOptions: true);
        default:
          saveInJson = false;
      }
      if (saveInJson) {
        _asJson[k] = data;
      }
    });
  }
}
