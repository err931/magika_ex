use magika::Session;
use rustler::{Binary, Env, NifResult, Resource, ResourceArc, Term};
use std::sync::Mutex;

struct MagikaResource {
    session: Mutex<Session>,
}

#[rustler::resource_impl]
impl Resource for MagikaResource {}

#[derive(rustler::NifStruct)]
#[module = "MagikaEx.Result"]
struct MagikaResult {
    /// The unique label identifying this file type.
    pub label: String,

    /// The MIME type of the file type.
    pub mime_type: String,

    /// The group of the file type.
    pub group: String,

    /// The description of the file type.
    pub description: String,

    /// The inference score between 0 and 1.
    pub score: f32,

    /// Whether the file type is text.
    pub is_text: bool,
}

#[rustler::nif]
fn new() -> NifResult<ResourceArc<MagikaResource>> {
    let session = Session::new().map_err(|e| {
        rustler::Error::Term(Box::new(format!("Failed to create Magika session: {e:?}")))
    })?;

    Ok(ResourceArc::new(MagikaResource {
        session: Mutex::new(session),
    }))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn identify_bytes(resource: ResourceArc<MagikaResource>, data: Binary) -> NifResult<MagikaResult> {
    let mut session = resource
        .session
        .lock()
        .map_err(|_| rustler::Error::Term(Box::new("Failed to lock magika session mutex")))?;

    let result = session
        .identify_content_sync(data.as_slice())
        .map_err(|e| rustler::Error::Term(Box::new(format!("Magika error: {e:?}"))))?;

    let info = result.info();

    Ok(MagikaResult {
        label: info.label.into(),
        mime_type: info.mime_type.into(),
        group: info.group.into(),
        description: info.description.into(),
        score: result.score(),
        is_text: info.is_text,
    })
}

fn on_load(env: Env, _info: Term) -> bool {
    env.register::<MagikaResource>().is_ok()
}

rustler::init!("Elixir.MagikaEx.Native", load = on_load);
