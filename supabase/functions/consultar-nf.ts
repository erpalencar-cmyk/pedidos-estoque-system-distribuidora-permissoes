// Supabase Edge Function: consultar-nf
// Deploy: supabase functions deploy consultar-nf

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FOCUS_API_URL = "https://homologacao.focusnfe.com.br"

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: {"Access-Control-Allow-Origin": "*"} })
  }

  try {
    const { chave, tipo } = await req.json()

    if (!chave || !tipo) {
      return new Response(
        JSON.stringify({ erro: "Chave e tipo são obrigatórios" }),
        { status: 400, headers: {"Content-Type": "application/json"} }
      )
    }

    const focusToken = Deno.env.get("FOCUS_NFE_TOKEN")
    const endpoint = tipo === 'NFCE' ? 'nfce' : 'nfe'

    // Consultar status
    const response = await fetch(`${FOCUS_API_URL}/v2/${endpoint}/${chave}`, {
      method: "GET",
      headers: {
        "Authorization": `Basic ${btoa(focusToken + ":")}`,
        "Content-Type": "application/json",
      }
    })

    const resultado = await response.json()

    return new Response(JSON.stringify({
      status: resultado.status,
      protocolo: resultado.protocolo,
      mensagem: resultado.mensagem,
      data_autorizacao: resultado.data_autorizacao
    }), {
      headers: {"Content-Type": "application/json"}
    })
  } catch (error) {
    return new Response(
      JSON.stringify({ erro: error.message }),
      { status: 500, headers: {"Content-Type": "application/json"} }
    )
  }
})
