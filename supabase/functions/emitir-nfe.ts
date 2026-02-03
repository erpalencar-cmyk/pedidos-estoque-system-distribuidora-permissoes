// Supabase Edge Function: emitir-nfe
// Deploy: supabase functions deploy emitir-nfe

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FOCUS_API_URL = "https://homologacao.focusnfe.com.br"

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: {"Access-Control-Allow-Origin": "*"} })
  }

  try {
    const { xml, vendor_id } = await req.json()

    if (!xml) {
      return new Response(
        JSON.stringify({ erro: "XML é obrigatório" }),
        { status: 400, headers: {"Content-Type": "application/json"} }
      )
    }

    const focusToken = Deno.env.get("FOCUS_NFE_TOKEN")

    // Enviar NF-e
    const response = await fetch(`${FOCUS_API_URL}/v2/nfe`, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${btoa(focusToken + ":")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        xml: xml,
        ref: vendor_id
      })
    })

    const resultado = await response.json()

    return new Response(JSON.stringify({
      numero: resultado.numero,
      chave: resultado.chave,
      protocolo: resultado.protocolo,
      status: response.ok ? "autorizada" : "rejeitada",
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
