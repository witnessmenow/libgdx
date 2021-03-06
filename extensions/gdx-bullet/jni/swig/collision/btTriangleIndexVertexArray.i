%module btIndexedMesh

%{
#include <BulletCollision/CollisionShapes/btTriangleIndexVertexArray.h>
%}

%extend btIndexedMesh {
	void setTriangleIndexBase(short *data) {
		$self->m_triangleIndexBase = (unsigned char*)data;
	}
	void setVertexBase(float *data) {
		$self->m_vertexBase = (unsigned char*)data;
	}
	void setVertices(float *vertices, int sizeInBytesOfEachVertex, int vertexCount, int positionOffsetInBytes) {
		unsigned char *data = (unsigned char *)vertices;
		$self->m_vertexBase = &(data[positionOffsetInBytes]);
		$self->m_vertexStride = sizeInBytesOfEachVertex;
		$self->m_numVertices = vertexCount;
		$self->m_vertexType = PHY_FLOAT;
	}
	void setIndices(short *indices, int indexOffset, int indexCount) {
		$self->m_triangleIndexBase = (unsigned char*)&(indices[indexOffset]);
		$self->m_triangleIndexStride = 3 * sizeof(short);
		$self->m_numTriangles = indexCount / 3;
		$self->m_indexType = PHY_SHORT;
	}
};

%typemap(javaimports) btIndexedMesh %{
import com.badlogic.gdx.physics.bullet.BulletBase;
import com.badlogic.gdx.physics.bullet.linearmath.*;
import com.badlogic.gdx.graphics.Mesh;
import com.badlogic.gdx.graphics.VertexAttribute;
import com.badlogic.gdx.graphics.VertexAttributes.Usage;
import com.badlogic.gdx.graphics.g3d.model.MeshPart;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.GdxRuntimeException;
%}

%typemap(javacode) btIndexedMesh %{
	protected final static Array<btIndexedMesh> instances = new Array<btIndexedMesh>();
	protected static btIndexedMesh getInstance(final MeshPart meshPart) {
		final int n = instances.size;
		for (int i = 0; i < n; i++) {
			final btIndexedMesh mesh = instances.get(i);
			if (meshPart.equals(mesh.meshPart))
				return mesh;
		}
		return null;
	}
	
	/** Create or reuse a btIndexedMesh instance based on the specified {@link MeshPart}.
	 * Use {@link #release()} to release the mesh when it's no longer needed. */
	public static btIndexedMesh obtain(final MeshPart meshPart) {
		if (meshPart == null)
			throw new GdxRuntimeException("meshPart cannot be null");
		
		btIndexedMesh result = getInstance(meshPart);
		if (result == null) {
			result = new btIndexedMesh(meshPart);
			instances.add(result);
		}
		result.obtain();
		return result;
	}
	
	protected MeshPart meshPart;
	
	/** Construct a new btIndexedMesh based on the supplied {@link Mesh}
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public btIndexedMesh(final Mesh mesh) {
		this();
		set(mesh);
	}
	
	/** Construct a new btIndexedMesh based on the supplied {@link MeshPart}
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public btIndexedMesh(final MeshPart meshPart) {
		this();
		set(meshPart);
	}
	
	/** Construct a new btIndexedMesh based on the supplied {@link Mesh}
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public btIndexedMesh(final Mesh mesh, int offset, int count) {
		this();
		set(mesh, offset, count);
	}
	
	/** @return The {@link MeshPart} used to create or set this btIndexedMesh, may be null. */
	public MeshPart getMeshPart() {
		return meshPart;
	}
	
	/** Convenience method to set this btIndexedMesh to the specified {@link Mesh} 
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public void set(final Mesh mesh) {
		set(mesh, 0, mesh.getNumIndices());
	}

	/** Convenience method to set this btIndexedMesh to the specified {@link MeshPart} 
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public void set(final MeshPart meshPart) {
		if (meshPart.primitiveType != com.badlogic.gdx.graphics.GL20.GL_TRIANGLES)
			throw new com.badlogic.gdx.utils.GdxRuntimeException("Mesh must be indexed and triangulated");
		set(meshPart.mesh, meshPart.indexOffset, meshPart.numVertices);
		this.meshPart = meshPart;
	}

	/** Convenience method to set this btIndexedMesh to the specified {@link Mesh} 
	 * The specified mesh must be indexed and triangulated and must outlive this btIndexedMesh.
	 * The buffers for the vertices and indices are shared amonst both. */
	public void set(final Mesh mesh, int offset, int count) {
		if ((count <= 0) || ((count % 3) != 0))
			throw new com.badlogic.gdx.utils.GdxRuntimeException("Mesh must be indexed and triangulated");

		VertexAttribute posAttr = mesh.getVertexAttribute(Usage.Position);
		
		if (posAttr == null)
			throw new com.badlogic.gdx.utils.GdxRuntimeException("Mesh doesn't have a position attribute");
		
		setVertices(mesh.getVerticesBuffer(), mesh.getVertexSize(), mesh.getNumVertices(), posAttr.offset);
		setIndices(mesh.getIndicesBuffer(), offset, count);
		
		meshPart = null;
	}
%}

%rename(internalAddIndexedMesh) btTriangleIndexVertexArray::addIndexedMesh;
%javamethodmodifiers btTriangleIndexVertexArray::addIndexedMesh "private";
%ignore btTriangleIndexVertexArray::btTriangleIndexVertexArray(int numTriangles,int* triangleIndexBase,int triangleIndexStride,int numVertices,btScalar* vertexBase,int vertexStride);
%ignore btTriangleIndexVertexArray::getIndexedMeshArray();

%typemap(javaimports) btTriangleIndexVertexArray %{
import com.badlogic.gdx.physics.bullet.BulletBase;
import com.badlogic.gdx.physics.bullet.linearmath.*;
import com.badlogic.gdx.math.Vector3;
import com.badlogic.gdx.math.Quaternion;
import com.badlogic.gdx.math.Matrix3;
import com.badlogic.gdx.math.Matrix4;
import com.badlogic.gdx.graphics.Mesh;
import com.badlogic.gdx.graphics.g3d.Model;
import com.badlogic.gdx.graphics.g3d.model.MeshPart;
import com.badlogic.gdx.graphics.g3d.model.NodePart;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.GdxRuntimeException;
%}

%typemap(javacode) btTriangleIndexVertexArray %{
	protected final static Array<btTriangleIndexVertexArray> instances = new Array<btTriangleIndexVertexArray>();
	
	/** @return Whether the supplied array is contains all specified mesh parts. */
	public static <T extends MeshPart> boolean compare(final btTriangleIndexVertexArray array, final Array<T> meshParts) {
		if (array.meshes.size != meshParts.size)
			return false;
		for (final btIndexedMesh mesh : array.meshes) {
			boolean found = false;
			final MeshPart mp = mesh.getMeshPart();
			if (mp == null) 
				return false;
			for (final MeshPart part : meshParts) {
				if (mp.equals(part)) {
					found = true;
					break;
				}
			}
			if (!found)
				return false;
		}
		return true;
	}

	protected static <T extends MeshPart> btTriangleIndexVertexArray getInstance(final Array<T> meshParts) {
		for (final btTriangleIndexVertexArray instance : instances) {
			if (compare(instance, meshParts))
				return instance;
		}
		return null;
	}
	
	/** Create or reuse a btTriangleIndexVertexArray instance based on the specified {@link MeshPart} array.
	 * Use {@link #release()} to release the mesh when it's no longer needed. */
	public static <T extends MeshPart> btTriangleIndexVertexArray obtain(final Array<T> meshParts) {
		btTriangleIndexVertexArray result = getInstance(meshParts);
		if (result == null) {
			result = new btTriangleIndexVertexArray(meshParts);
			instances.add(result);
		}
		result.obtain();
		return result;
	}
	
	protected final Array<btIndexedMesh> meshes = new Array<btIndexedMesh>(1);
	
	public btTriangleIndexVertexArray(final MeshPart meshPart) {
		this();
		addMeshPart(meshPart);
	}
	
	public <T extends MeshPart> btTriangleIndexVertexArray(final Iterable<T> meshParts) {
		this();
		addMeshParts(meshParts);
	}
	
	/** The amount of meshes this array contains. */
	public int getIndexedMeshCount() {
		return meshes.size;
	}
	
	/** Return the {@link btIndexedMesh} at the specified index. */
	public btIndexedMesh getIndexedMesh(int index) {
		return meshes.get(index);
	}

	/** Add a {@link MeshPart} instance to this btTriangleIndexVertexArray. 
	 * The specified mesh must be indexed and triangulated and must outlive this btTriangleIndexVertexArray.
     * The buffers for the vertices and indices are shared amongst both. */
	public btTriangleIndexVertexArray addMeshPart(final MeshPart meshPart) {
		btIndexedMesh mesh = btIndexedMesh.obtain(meshPart);
		addIndexedMesh(mesh, PHY_ScalarType.PHY_SHORT);
		mesh.release();
		return this;
	}

	/** Add one or more {@link MeshPart} instances to this btTriangleIndexVertexArray. 
	 * The specified meshes must be indexed and triangulated and must outlive this btTriangleIndexVertexArray.
     * The buffers for the vertices and indices are shared amongst both. */
	public btTriangleIndexVertexArray addMeshParts(final MeshPart... meshParts) {
		for (int i = 0; i < meshParts.length; i++)
			addMeshPart(meshParts[i]);
		return this;
	}

	/** Add one or more {@link MeshPart} instances to this btTriangleIndexVertexArray. 
	 * The specified meshes must be indexed and triangulated and must outlive this btTriangleIndexVertexArray.
     * The buffers for the vertices and indices are shared amongst both. */
	public <T extends MeshPart> btTriangleIndexVertexArray addMeshParts(final Iterable<T> meshParts) {
		for (final MeshPart meshPart : meshParts)
			addMeshPart(meshPart);
		return this;
	}
	
	/** Add one or more {@link NodePart} instances to this btTriangleIndexVertexArray. 
	 * The specified meshes must be indexed and triangulated and must outlive this btTriangleIndexVertexArray.
     * The buffers for the vertices and indices are shared amongst both. */
	public <T extends NodePart> btTriangleIndexVertexArray addNodeParts(final Iterable<T> nodeParts) {
		for (final NodePart nodePart : nodeParts)
			addMeshPart(nodePart.meshPart);
		return this;
	}
	
	/** Add a {@link btIndexedMesh} to this array */
	public btTriangleIndexVertexArray addIndexedMesh(final btIndexedMesh mesh, int indexType) {
		mesh.obtain();
		internalAddIndexedMesh(mesh, indexType);
		meshes.add(mesh);
		return this;
	}

	/** Add a {@link btIndexedMesh} to this array */
	public btTriangleIndexVertexArray addIndexedMesh(final btIndexedMesh mesh) {
		return addIndexedMesh(mesh, PHY_ScalarType.PHY_SHORT);
	}
	
	@Override
	public void dispose() {
		for (final btIndexedMesh mesh : meshes)
			mesh.release();
		meshes.clear();
		super.dispose();
	}
%}

%include "BulletCollision/CollisionShapes/btTriangleIndexVertexArray.h"
