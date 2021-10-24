# BirdLancer code style guidelines

This project uses the [**code styling guidelines provided by GDQuest**](https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/).

**Additional caveats:**
- Signal connections in code are preferred, so that they can be seen also by users of external editors.
- If a method has more than one possible return type, avoid writing the `-> [type]:` after the declaration - this must be read as "Variant return type".
- Try to avoid multi-type variables, but if it can't be avoided don't write the `: [type]` - this must be read as "Variant variable type".
- Static functions must be put before all the other methods.
- If possible, avoid assigning a script to an existing node without saving them both as a new scene, in particular if the script has exported variables. This helps to maintain an ordered project with clearly defined scene responsabilities and reduces the risk for another programmer to "reinvent the wheel".
