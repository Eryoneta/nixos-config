{ tools, ... }: with tools; {
  config = {

    # Default Text Editor
    environment.variables.EDITOR = "kwrite";

  };
}
