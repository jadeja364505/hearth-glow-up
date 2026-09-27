import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
export function useCurrentUser(){return useQuery({queryKey:["current-user"],queryFn:async()=>{const {data,error}=await supabase.auth.getUser();if(error)throw error;return data.user},staleTime:60_000})}
export function useTemplates(){return useQuery({queryKey:["templates"],queryFn:async()=>{const {data,error}=await supabase.from("certificate_templates").select("*").order("updated_at",{ascending:false});if(error)throw error;return data}})}
export function useJobs(){return useQuery({queryKey:["jobs"],queryFn:async()=>{const {data,error}=await supabase.from("generation_jobs").select("*, certificate_templates(name)").order("created_at",{ascending:false});if(error)throw error;return data}})}
export function useProfile(){return useQuery({queryKey:["profile"],queryFn:async()=>{const {data:{user}}=await supabase.auth.getUser();if(!user)throw new Error("Not signed in");const {data,error}=await supabase.from("profiles").select("*").eq("id",user.id).single();if(error)throw error;return {...data,email:user.email??""}}})}
