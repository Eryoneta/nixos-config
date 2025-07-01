lib: {
  mkIfElse = condition: content: elseContent: (
    lib.mkMerge [
      (lib.mkIf condition content)
      (lib.mkIf (!condition) elseContent)
    ]
  );
}
