// Supabase Edge Function: cancelar-nf
// Deploy: supabase functions deploy cancelar-nf

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FOCUS_API_URL = "https://homologacao.focusnfe.com.br"

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: {"Access-Control-Allow-Origin": "*"} })
  }

  try {
    const { chave, motivo, tipo } = await req.json()

    if (!chave || !motivo) {
      return new Response(
        JSON.stringify({ erro: "Chave e motivo são obrigatórios" }),
        { status: 400, headers: {"Content-Type": "application/json"} }
      )
    }

    const focusToken = Deno.env.get("FOCUS_NFE_TOKEN")
    const endpoint = tipo === 'NFCE' ? 'nfce' : 'nfe'

    // Cancelar NF
    const response = await fetch(`${FOCUS_API_URL}/v2/${endpoint}/${chave}/cancelamento`, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${btoa(focusToken + ":")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        motivo: motivo
      })
    })

    const resultado = await response.json()

    return new Response(JSON.stringify({
      sucesso: response.ok,
      protocolo: resultado.protocolo,
      mensagem: resultado.mensagem
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
