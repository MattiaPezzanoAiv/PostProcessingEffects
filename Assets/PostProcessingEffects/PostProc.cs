using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProc : MonoBehaviour
{
    public Material Mat;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, Mat);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            StartCoroutine(TransitWithFlash());
        }
        if (Input.GetKeyDown(KeyCode.R))
        {
            Mat.SetFloat("_CutOff", 0f);
        }
    }

    public float time = 1f;
    public float flashTime = 0.15f;
    public int flashCount = 2;

    IEnumerator TransitSimple()
    {
        Mat.SetFloat("_CutOff", 0f);
        float speed = 1f / time;
        float current = 0f;
        for (float i = 0; i < time; i += Time.deltaTime)
        {
            current += speed = Time.deltaTime;
            Mat.SetFloat("_CutOff", current);
            yield return null;
        }
        Mat.SetFloat("_CutOff", 1f);
    }

    IEnumerator TransitWithFlash()
    {
        Mat.SetFloat("_CutOff", 0f);
        Mat.SetFloat("_Fade", 0f);

        for (int i = 0; i < flashCount; i++)
        {
            float currentFade = 0f;
            float fadeSpeed = 1f / flashTime;
            for (float j = 0; j < flashTime; j += Time.deltaTime)
            {
                currentFade += fadeSpeed * Time.deltaTime;
                Mat.SetFloat("_Fade", currentFade);
                yield return null;
            }
            for (float j = 0; j < flashTime; j += Time.deltaTime)
            {
                currentFade -= fadeSpeed * Time.deltaTime;
                Mat.SetFloat("_Fade", currentFade);
                yield return null;
            }
        }
        Mat.SetFloat("_Fade", 0f);

        float speed = 1f / time;
        float current = 0f;
        for (float i = 0; i < time; i += Time.deltaTime)
        {
            current += speed = Time.deltaTime;
            Mat.SetFloat("_CutOff", current);
            yield return null;
        }
        for (float i = 0; i < time; i += Time.deltaTime)
        {
            current -= speed = Time.deltaTime;
            Mat.SetFloat("_CutOff", current);
            yield return null;
        }
        Mat.SetFloat("_CutOff", 0f);
    }
}
