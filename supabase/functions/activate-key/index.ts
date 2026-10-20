import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
async function sha256(s:string){const d=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(s));return [...new Uint8Array(d)].map(b=>b.toString(16).padStart(2,"0")).join("")}
Deno.serve(async req=>{
 if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
 if(req.method!=="POST")return new Response(JSON.stringify({error:"Method not allowed"}),{status:405,headers:{...cors,"Content-Type":"application/json"}});
 try{
  const {key,deviceFingerprint}=await req.json();
  if(typeof key!=="string"||key.trim().length<8||typeof deviceFingerprint!=="string"||deviceFingerprint.length<8||deviceFingerprint.length>200)
   return new Response(JSON.stringify({error:"A valid key and device fingerprint are required."}),{status:400,headers:{...cors,"Content-Type":"application/json"}});
  const url=Deno.env.get("SUPABASE_URL"), secret=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if(!url||!secret)throw new Error("Missing server config");
  const db=createClient(url,secret,{auth:{persistSession:false}});
  const kh=await sha256(key.trim().toUpperCase()), dh=await sha256(deviceFingerprint);
  const {data:k,error}=await db.from("access_keys").select("id,status,expires_at,max_devices,duration_code").eq("key_hash",kh).maybeSingle();
  if(error)throw error;
  if(!k||k.status!=="active")return new Response(JSON.stringify({ok:false,error:"Key is invalid or inactive."}),{status:401,headers:{...cors,"Content-Type":"application/json"}});
  if(k.expires_at&&new Date(k.expires_at).getTime()<=Date.now()){await db.from("access_keys").update({status:"expired"}).eq("id",k.id);return new Response(JSON.stringify({ok:false,error:"This key has expired."}),{status:401,headers:{...cors,"Content-Type":"application/json"}})}
  const {data:existing,error:ee}=await db.from("key_activations").select("id").eq("access_key_id",k.id).eq("device_fingerprint_hash",dh).maybeSingle();if(ee)throw ee;
  if(!existing){const {count,error:ce}=await db.from("key_activations").select("id",{count:"exact",head:true}).eq("access_key_id",k.id);if(ce)throw ce;if((count??0)>=k.max_devices)return new Response(JSON.stringify({ok:false,error:"Device limit reached. Contact the administrator."}),{status:403,headers:{...cors,"Content-Type":"application/json"}});const {error:ie}=await db.from("key_activations").insert({access_key_id:k.id,device_fingerprint_hash:dh});if(ie)throw ie}
  else await db.from("key_activations").update({last_seen_at:new Date().toISOString()}).eq("id",existing.id);
  return new Response(JSON.stringify({ok:true,duration:k.duration_code,message:"Key accepted. Implement protected profile/download authorization before exposing content."}),{status:200,headers:{...cors,"Content-Type":"application/json"}});
 }catch(_){return new Response(JSON.stringify({error:"Server error. Check Edge Function configuration and logs."}),{status:500,headers:{...cors,"Content-Type":"application/json"}})}
});
