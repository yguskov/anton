class MyWizardStep {
  var _controller;
  var _field;

  MyWizardStep(this._field, this._controller);

  String getValue(name) {
    return _field[name]!.value;
    // return _description.value;
  }

  void updateValue(String name, String value) {
    _field[name]!.add(value);
  }

  controllerByName(String field) {
    return _controller[field];
  }
}
