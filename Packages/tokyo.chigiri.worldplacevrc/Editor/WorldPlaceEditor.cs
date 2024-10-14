using UnityEditor;
using UnityEngine;

namespace tokyo.chigiri.worldplacevrc.editor
{

    public class WorldPlaceEditor
    {

        const string FEATURE_NAME = "WorldPlace";
        const string WORLDPLACE_PREFAB_GUID = "546643312472edf429565a17bdb578ec";

        [MenuItem("GameObject/PasocomMate/WorldPlace", priority=21)]
        static void CreateWorldPlace()
        {
            var path = AssetDatabase.GUIDToAssetPath(WORLDPLACE_PREFAB_GUID);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            var go = GameObject.Instantiate(prefab);
            go.name = FEATURE_NAME;
            go.transform.SetParent(Selection.activeGameObject.transform, false);
            Undo.RegisterCreatedObjectUndo(go, $"Create {FEATURE_NAME}");
            Selection.activeGameObject = go;
        }

    }

}
