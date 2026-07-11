use std::{path::PathBuf, sync::Mutex};

use magika::{FileType, Session};
use rustler::{Binary, Env, Resource, ResourceArc, Term};

impl From<FileType> for MagikaResult {
    fn from(result: FileType) -> Self {
        let info = result.info();
        MagikaResult {
            label: info.label.into(),
            mime_type: info.mime_type.into(),
            group: info.group.into(),
            description: info.description.into(),
            score: result.score(),
            is_text: info.is_text,
        }
    }
}

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
fn new() -> Result<ResourceArc<MagikaResource>, String> {
    let session = Session::new().map_err(|e| e.to_string())?;

    Ok(ResourceArc::new(MagikaResource {
        session: Mutex::new(session),
    }))
}

#[rustler::nif]
fn model_name() -> &'static str {
    magika::MODEL_NAME
}

#[rustler::nif(schedule = "DirtyCpu")]
fn identify_bytes(
    resource: ResourceArc<MagikaResource>,
    data: Binary,
) -> Result<MagikaResult, String> {
    let mut session = resource.session.lock().map_err(|e| e.to_string())?;

    session
        .identify_content_sync(data.as_slice())
        .map(MagikaResult::from)
        .map_err(|e| e.to_string())
}

#[rustler::nif(schedule = "DirtyCpu")]
fn identify_path(
    resource: ResourceArc<MagikaResource>,
    path: String,
) -> Result<MagikaResult, String> {
    let mut session = resource.session.lock().map_err(|e| e.to_string())?;

    session
        .identify_file_sync(PathBuf::from(path))
        .map(MagikaResult::from)
        .map_err(|e| e.to_string())
}

fn on_load(env: Env, _info: Term) -> bool {
    env.register::<MagikaResource>().is_ok()
}

rustler::init!("Elixir.MagikaEx.Native", load = on_load);
