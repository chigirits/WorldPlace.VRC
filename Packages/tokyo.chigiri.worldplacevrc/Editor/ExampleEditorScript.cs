using UnityEditor;

namespace tokyo.chigiri.worldplacevrc.editor
{

    public class ExampleEditorScript
    {
        [MenuItem("Tools/WorldPlace.VRC/Test")]
        static void Test()
        {
            EditorUtility.DisplayDialog("Example Script", "Opened This Dialog", "OK");
        }
    }

}
